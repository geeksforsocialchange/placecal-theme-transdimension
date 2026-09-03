# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# rubocop:disable Metrics/BlockLength
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
  # record it gets back.
  def stub_site_lookup(site, slug: 'trans-dimension')
    allow(site.logo).to receive_messages(present?: true, file: double(present?: true))
    allow(site.hero_image).to receive_messages(present?: true, file: double(present?: true))
    allow(Site).to receive(:find_by).with(slug: slug).and_return(site)
  end

  def create_td_site(**overrides)
    create(:site, {
      slug: 'trans-dimension',
      name: 'The Trans Dimension',
      url: 'https://transdimension.uk',
      theme: 'transdimension',
      is_published: true,
      contact_email: 'contact@transdimension.uk',
      site_admin: create(:root_user)
    }.merge(overrides))
  end

  def add_partnership_tags(site)
    site.tags << [create(:partnership, name: 'London'), create(:partnership, name: 'Manchester')]
  end

  describe 'with a fully configured Trans Dimension site' do
    before do
      site = create_td_site
      add_partnership_tags(site)
      stub_site_lookup(site)
    end

    it 'exits zero' do
      _output, status = run_check

      expect(status).to eq(0)
    end

    it 'passes every check' do
      output, = run_check

      expect(output).to include(
        'PASS: Site exists and is published',
        'PASS: URL is present and uses HTTPS (https://transdimension.uk)',
        'PASS: Theme is set to transdimension',
        'PASS: Contact email is present and valid (contact@transdimension.uk)',
        'PASS: Site admin is set',
        'PASS: Logo is present',
        'PASS: Hero image is present',
        'PASS: No neighbourhoods configured (as expected)'
      )
    end

    it 'reports the London and Manchester partnership tags' do
      output, = run_check

      expect(output).to match(/PASS: Partnership tags include London \(id: \d+\) and Manchester \(id: \d+\)/)
    end

    it 'reports nothing that failed or needs attention' do
      output, = run_check

      expect(output).not_to include('FAIL', 'WARN')
    end
  end

  describe 'with the wrong theme' do
    before do
      site = create_td_site(theme: 'pink')
      add_partnership_tags(site)
      stub_site_lookup(site)
    end

    it 'fails the theme check and exits one' do
      output, status = run_check

      expect(output).to include("FAIL: Theme is 'pink', expected 'transdimension'")
      expect(status).to eq(1)
    end
  end

  describe 'when the site does not exist' do
    it 'fails with the missing site and exits one' do
      output, status = run_check

      expect(output).to include("FAIL: Site with slug 'trans-dimension' not found")
      expect(status).to eq(1)
    end
  end

  describe 'with neighbourhoods configured' do
    before do
      site = create_td_site
      add_partnership_tags(site)
      site.neighbourhoods << create(:riverside_ward)
      stub_site_lookup(site)
    end

    it 'warns about the neighbourhoods but does not fail' do
      output, status = run_check

      expect(output).to include('WARN: Site has neighbourhoods (expected none)')
      expect(output).not_to include('FAIL')
      expect(status).to eq(0)
    end
  end

  describe 'choosing which site to check' do
    it 'takes the slug from the rake argument' do
      site = create_td_site(slug: 'another-td')
      add_partnership_tags(site)
      stub_site_lookup(site, slug: 'another-td')

      _output, status = run_check('another-td')

      expect(status).to eq(0)
    end

    it 'falls back to TD_SITE_SLUG when no argument is given' do
      site = create_td_site(slug: 'env-td')
      add_partnership_tags(site)
      stub_site_lookup(site, slug: 'env-td')

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
# rubocop:enable Metrics/BlockLength
