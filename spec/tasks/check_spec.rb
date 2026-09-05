# frozen_string_literal: true

require 'rails_helper'
require 'rake'
require 'tmpdir'

describe 'transdimension:check rake task', type: :task do
  before { Rails.application.load_tasks if Rake::Task.tasks.empty? }

  # The task reports on stdout and calls exit(1) when a check fails. Capture
  # both so the examples can assert on what an operator would actually see.
  # Returns [output, exit_status], with a status of 0 when the task did not
  # exit.
  def run_check(*args)
    status = 0
    output = capture_stdout do
      task = Rake::Task['transdimension:check']
      task.reenable
      task.invoke(*args)
    rescue SystemExit => e
      status = e.status
    end
    [output, status]
  end

  def capture_stdout
    captured = StringIO.new
    original = $stdout
    $stdout = captured
    begin
      yield
    ensure
      $stdout = original
    end
    captured.string
  end

  # The task looks the Site up itself, so nothing here stubs Site.find_by: the
  # slug-selection examples have to exercise the query the task really runs.
  # The logo and hero image are real uploads for the same reason.
  def configured_site(slug: 'trans-dimension', **overrides)
    site = create_site(slug, overrides)
    site.tags << [create(:partnership, name: 'London'), create(:partnership, name: 'Manchester')]
    site.neighbourhoods << create(:normal_island_country)
    attach_images(site)
    site
  end

  # CarrierWave writes under the host app's public/ and the hero uploader resizes
  # into four versions. Neither belongs in a theme spec run, so the uploads go to
  # a tmpdir and processing is off, which also means the run needs no
  # ImageMagick. What the task checks is only that a file is attached.
  around do |example|
    Dir.mktmpdir do |dir|
      original_root = CarrierWave::Uploader::Base.root
      CarrierWave::Uploader::Base.root = dir
      CarrierWave::Uploader::Base.enable_processing = false
      begin
        example.run
      ensure
        CarrierWave::Uploader::Base.enable_processing = true
        CarrierWave::Uploader::Base.root = original_root
      end
    end
  end

  def attach_images(site)
    fixture = PLACECAL_CORE.join('spec/fixtures/files/test-image.png')
    File.open(fixture) { |f| site.logo = f }
    File.open(fixture) { |f| site.hero_image = f }
    site.save!
  end

  def create_site(slug, overrides)
    create(:site, {
      slug: slug,
      name: 'The Trans Dimension',
      url: 'https://transdimension.uk',
      theme: 'transdimension',
      is_published: true,
      contact_email: 'contact@transdimension.uk',
      site_admin: create(:root_user)
    }.merge(overrides))
  end

  it 'passes every check on a fully configured site' do
    configured_site

    output, status = run_check

    expect(status).to eq(0)
    expect(output).to include(
      'PASS: Site exists and is published',
      'PASS: URL is present and uses HTTPS (https://transdimension.uk)',
      'PASS: Theme is set to transdimension',
      'PASS: Contact email is present and valid (contact@transdimension.uk)',
      'PASS: Site admin is set',
      'PASS: Logo is present',
      'PASS: Hero image is present'
    )
    expect(output).to match(/PASS: Partnership tags include London \(id: \d+\) and Manchester \(id: \d+\)/)
    expect(output).to include('PASS: One country neighbourhood')
    expect(output).not_to include('FAIL', 'WARN')
  end

  it 'reports a failing check and exits one' do
    configured_site(theme: 'pink')

    output, status = run_check

    expect(output).to include("FAIL: Theme is 'pink', expected 'transdimension'")
    expect(status).to eq(1)
  end

  it 'warns when the neighbourhood is not the single country node' do
    site = configured_site
    site.neighbourhoods << create(:riverside_ward)

    output, status = run_check

    expect(output).to include('WARN: Expected one country neighbourhood, found:')
    expect(output).not_to include('FAIL')
    expect(status).to eq(0)
  end

  describe 'choosing which site to check' do
    it 'takes the slug from the rake argument' do
      configured_site(slug: 'another-td')

      _output, status = run_check('another-td')

      expect(status).to eq(0)
    end

    it 'falls back to TD_SITE_SLUG when no argument is given' do
      configured_site(slug: 'env-td')
      ENV['TD_SITE_SLUG'] = 'env-td'

      _output, status = run_check

      expect(status).to eq(0)
    ensure
      ENV.delete('TD_SITE_SLUG')
    end

    it 'names the slug it was given when the site is missing' do
      output, status = run_check('no-such-site')

      expect(output).to include("FAIL: Site with slug 'no-such-site' not found")
      expect(status).to eq(1)
    end
  end
end
