# frozen_string_literal: true

require 'rails_helper'
require 'rake'

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

  # The task loads the Site itself, so the uploader stubs have to be on the
  # record it gets back. Those two checks therefore assert the task's own
  # reporting rather than any real uploader behaviour.
  def configured_site(slug: 'trans-dimension', **overrides)
    site = create_site(slug, overrides)
    site.tags << [create(:partnership, name: 'London'), create(:partnership, name: 'Manchester')]
    site.neighbourhoods << create(:normal_island_country)
    stub_uploaders(site)
    allow(Site).to receive(:find_by).with(slug: slug).and_return(site)
    site
  end

  def stub_uploaders(site)
    allow(site.logo).to receive_messages(present?: true, file: double(present?: true))
    allow(site.hero_image).to receive_messages(present?: true, file: double(present?: true))
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
