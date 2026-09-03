# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :transdimension do
  # Takes the site slug as a rake argument. TD_SITE_SLUG stays as a fallback
  # for callers that cannot pass one.
  #
  # The task checks the Site record only. The theme's About and Privacy pages
  # are views in this engine rather than rows in the host database (WP 3.12),
  # so there is nothing about them for an operator to get wrong; spec/requests/
  # pages_spec.rb covers that they render.
  desc 'Verify the Trans Dimension Site record is configured correctly'
  task :check, [:site_slug] => :environment do |_t, args|
    site_slug = args[:site_slug].presence || ENV.fetch('TD_SITE_SLUG', 'trans-dimension')
    site = Site.find_by(slug: site_slug)

    if site.nil?
      puts "FAIL: Site with slug '#{site_slug}' not found"
      exit(1)
    end

    # Each check returns one line, prefixed PASS, WARN or FAIL. Anything that
    # comes back FAIL exits the task non-zero; a WARN is for the operator to
    # look at without blocking the deploy.
    checks = [
      -> { site.is_published ? 'PASS: Site exists and is published' : 'FAIL: Site is not published' },
      lambda {
        if site.url.present? && site.url.start_with?('https://')
          "PASS: URL is present and uses HTTPS (#{site.url})"
        else
          'FAIL: URL is missing or does not start with https://'
        end
      },
      lambda {
        if site.theme == 'transdimension'
          'PASS: Theme is set to transdimension'
        else
          "FAIL: Theme is '#{site.theme}', expected 'transdimension'"
        end
      },
      lambda {
        tags = site.tags.where(type: 'Partnership').pluck(:name, :id)
        found = %w[London Manchester].to_h do |wanted|
          [wanted, tags.find { |name, _id| name.casecmp(wanted).zero? }]
        end
        missing = found.select { |_wanted, tag| tag.nil? }.keys

        if missing.any?
          "FAIL: Missing partnership tags: #{missing.join(', ')}"
        else
          'PASS: Partnership tags include ' \
            "London (id: #{found['London'].last}) and Manchester (id: #{found['Manchester'].last})"
        end
      },
      lambda {
        if site.contact_email.blank?
          'FAIL: Contact email is not set'
        elsif site.contact_email.match?(URI::MailTo::EMAIL_REGEXP)
          "PASS: Contact email is present and valid (#{site.contact_email})"
        else
          "FAIL: Contact email format is invalid (#{site.contact_email})"
        end
      },
      lambda {
        if site.site_admin.present?
          "PASS: Site admin is set (#{site.site_admin.display_name})"
        else
          'FAIL: Site admin is not set'
        end
      },
      lambda {
        site.logo.present? && site.logo.file.present? ? 'PASS: Logo is present' : 'FAIL: Logo is not present'
      },
      lambda {
        if site.hero_image.present? && site.hero_image.file.present?
          'PASS: Hero image is present'
        else
          'FAIL: Hero image is not present'
        end
      },
      # doc/site-record.md asks for exactly one neighbourhood, the United
      # Kingdom country node: the partnership tags do the real scoping, and a
      # narrower neighbourhood would hide partners outside it.
      lambda {
        hoods = site.neighbourhoods.to_a

        if hoods.one? && hoods.first.unit == 'country'
          "PASS: One country neighbourhood (#{hoods.first.name})"
        elsif hoods.empty?
          'WARN: No neighbourhood set (expected the United Kingdom country node)'
        else
          "WARN: Expected one country neighbourhood, found: #{hoods.map(&:name).join(', ')}"
        end
      }
    ]

    results = checks.map(&:call)
    %w[PASS WARN FAIL].each do |prefix|
      results.grep(/\A#{prefix}/).each { |line| puts line }
    end

    exit(1) if results.any? { |line| line.start_with?('FAIL') }
  end
end
# rubocop:enable Metrics/BlockLength
