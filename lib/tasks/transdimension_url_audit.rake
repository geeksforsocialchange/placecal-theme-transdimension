# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :transdimension do
  desc 'Audit Trans Dimension URLs for compatibility with PlaceCal'
  # Checks every legacy Trans Dimension path three ways: the live TD site, the
  # live PlaceCal deployment, and a local dev server running this branch. The
  # dev column is what tells you whether a routing fix on the branch works,
  # since the fix is not on placecal.org until it deploys.
  #
  # Every host is read from the environment, so the task carries no site
  # knowledge beyond the defaults:
  #   TD_BASE_URL     default https://transdimension.uk
  #   PC_BASE_URL     default https://placecal.org
  #   DEV_BASE_URL    default http://transdimension.lvh.me:3030 (set to '' to skip)
  #   AUDIT_ROUTE_HOST default transdimension.lvh.me, the host route
  #                    recognition runs against
  #   AUDIT_URLS_FILE  default doc/audits/transdimension-url-audit-urls.txt
  #   AUDIT_OUTPUT_DIR default doc/audits
  task 'url_audit', [:urls_file] => :environment do |_t, args|
    urls_file = args[:urls_file] ||
                ENV.fetch('AUDIT_URLS_FILE', 'doc/audits/transdimension-url-audit-urls.txt')

    unless File.exist?(urls_file)
      puts "ERROR: URLs file not found: #{urls_file}"
      exit 1
    end

    require 'net/http'
    require 'uri'
    require 'fileutils'

    td_base = ENV.fetch('TD_BASE_URL', 'https://transdimension.uk')
    pc_base = ENV.fetch('PC_BASE_URL', 'https://placecal.org')
    dev_base = ENV.fetch('DEV_BASE_URL', 'http://transdimension.lvh.me:3030')
    dev_base = nil if dev_base.blank?

    request_status = lambda do |base, path|
      uri = URI("#{base}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = 5
      http.read_timeout = 5
      http.request(Net::HTTP::Head.new(uri.request_uri)).code.to_i
    rescue StandardError
      'ERROR'
    end

    # A single dropped connection or a dev server reloading mid-run should not
    # be reported as a broken URL, so retry anything that is not a real answer.
    head_status = lambda do |base, path|
      status = request_status.call(base, path)
      return status unless status == 'ERROR' || (status.is_a?(Integer) && status >= 500)

      sleep 1
      request_status.call(base, path)
    end

    # A path that answers with any of these is reachable, redirect included.
    reachable = [200, 301, 302, 308].freeze

    # Read URLs
    paths = File.readlines(urls_file).map(&:strip).reject(&:empty?)

    results = []

    # Set up route recognition for transdimension site
    original_url_options = Rails.application.routes.default_url_options
    route_host = ENV.fetch('AUDIT_ROUTE_HOST', 'transdimension.lvh.me')
    Rails.application.routes.default_url_options = { host: route_host }

    puts "Auditing #{paths.length} URLs..."
    puts "  TD:  #{td_base}"
    puts "  PC:  #{pc_base}"
    puts "  DEV: #{dev_base || '(skipped)'}"
    puts ''

    paths.each_with_index do |path, idx|
      print "\r[#{idx + 1}/#{paths.length}] #{path}".ljust(80)

      # Check PlaceCal route
      begin
        route_match = Rails.application.routes.recognize_path(path, method: :get)
        route_result = "#{route_match[:controller]}##{route_match[:action]}"
      rescue ActionController::RoutingError
        route_result = 'NO ROUTE'
      end

      td_status = head_status.call(td_base, path)
      pc_status = head_status.call(pc_base, path)
      dev_status = dev_base ? head_status.call(dev_base, path) : nil

      # The dev server runs this branch, so it decides the verdict when it is
      # available. A path that 404s in dev but works in production is missing
      # local seed data, not a missing route.
      subject_status = dev_status || pc_status

      verdict = if route_result == 'NO ROUTE'
                  'NO ROUTE'
                elsif subject_status == 'ERROR'
                  'CHECK FAILED'
                elsif reachable.include?(subject_status)
                  'OK'
                elsif subject_status == 404 && dev_status == 404 && reachable.include?(pc_status)
                  'NO DEV DATA'
                elsif subject_status == 404
                  'MISSING'
                else
                  "UNKNOWN (#{subject_status})"
                end

      results << {
        path: path,
        td_status: td_status,
        route: route_result,
        pc_status: pc_status,
        dev_status: dev_status,
        verdict: verdict
      }

      # Rate limit
      sleep 0.3 if idx < paths.length - 1
    end

    Rails.application.routes.default_url_options = original_url_options

    # Group by verdict for the report's summary table. The report file is the
    # output that matters; the console just names it.
    by_verdict = results.group_by { |r| r[:verdict] }
    counts = ->(key) { by_verdict[key]&.length || 0 }

    # Write markdown table
    output_dir = ENV.fetch('AUDIT_OUTPUT_DIR', 'doc/audits')
    FileUtils.mkdir_p(output_dir)
    output_file = File.join(output_dir, "transdimension-url-audit-#{Time.zone.today}.md")

    File.open(output_file, 'w') do |f|
      f.puts '# Trans Dimension URL audit'
      f.puts ''
      f.puts "Date: #{Time.zone.today}"
      f.puts ''
      f.puts "TD: #{td_base}"
      f.puts ''
      f.puts "PlaceCal (production): #{pc_base}"
      f.puts ''
      f.puts "Dev (this branch): #{dev_base || '(skipped)'}"
      f.puts ''
      f.puts '## Summary'
      f.puts ''
      f.puts '| Verdict | Count |'
      f.puts '|---------|-------|'
      f.puts "| OK | #{counts.call('OK')} |"
      f.puts "| NO DEV DATA | #{counts.call('NO DEV DATA')} |"
      f.puts "| MISSING | #{counts.call('MISSING')} |"
      f.puts "| NO ROUTE | #{counts.call('NO ROUTE')} |"
      f.puts "| CHECK FAILED | #{counts.call('CHECK FAILED')} |"
      f.puts ''
      f.puts '## Details'
      f.puts ''
      f.puts '| Path | TD Status | Route | PC Status | Dev Status | Verdict |'
      f.puts '|------|-----------|-------|-----------|------------|---------|'

      results.each do |r|
        f.puts "| `#{r[:path]}` | #{r[:td_status]} | #{r[:route]} | #{r[:pc_status]} | " \
               "#{r[:dev_status] || 'n/a'} | #{r[:verdict]} |"
      end
    end

    puts ''
    puts "Audit report written to: #{output_file}"
  end
end
# rubocop:enable Metrics/BlockLength
