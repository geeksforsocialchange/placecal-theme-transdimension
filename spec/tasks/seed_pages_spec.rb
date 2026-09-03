# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# rubocop:disable Metrics/BlockLength
describe 'transdimension:seed_pages rake task', type: :task do
  before { Rails.application.load_tasks if Rake::Task.tasks.empty? }

  let(:site) { create(:site, slug: 'td-test', theme: 'transdimension', url: 'https://td-test.lvh.me') }

  def run_task(slug = nil)
    task = Rake::Task['transdimension:seed_pages']
    task.reenable
    if slug
      task.invoke(slug)
    else
      task.invoke
    end
  end

  context 'when task succeeds' do
    def invoke_task
      run_task(site.slug)
    end

    it 'creates About and Privacy pages' do
      expect { invoke_task }.to change(Page, :count).by(2)

      about = site.pages.find_by(slug: 'about')
      privacy = site.pages.find_by(slug: 'privacy')

      expect(about).to be_present
      expect(privacy).to be_present
    end

    it 'seeds About page with correct attributes and content' do
      invoke_task

      about = site.pages.find_by(slug: 'about')
      expect(about.title).to eq('About')
      expect(about.position).to eq(10)
      expect(about.show_in_nav).to be true
      expect(about.is_published).to be true
      expect(about.body_html).to be_present

      # Check body contains all expected sections
      expect(about.body).to include('We see and experience the barriers')
      expect(about.body).to include('Our Accessibility Process')
      expect(about.body).to include('Meet the Makers')
      expect(about.body).to include('Gendered Intelligence')
      expect(about.body).to include('Geeks for Social Change')
      expect(about.body).to include('Built using PlaceCal')
    end

    it 'seeds Privacy page with correct attributes and content' do
      invoke_task

      privacy = site.pages.find_by(slug: 'privacy')
      expect(privacy.title).to eq('Privacy Policy')
      expect(privacy.body).to start_with('The Trans Dimension is committed to protecting your privacy online.')
      expect(privacy.position).to eq(20)
      expect(privacy.show_in_nav).to be false
      expect(privacy.is_published).to be true
      expect(privacy.body).to include('This page explains')
      expect(privacy.body_html).to be_present
    end

    it 'names the analytics and font services the site actually uses' do
      invoke_task

      privacy = site.pages.find_by(slug: 'privacy')
      expect(privacy.body).to include('Matomo', 'stats.gfsc.community', 'Adobe Typekit')
      expect(privacy.body).not_to include('Plausible', 'Plausable', 'newsletter')
    end

    it 'is idempotent' do
      invoke_task
      about_first = site.pages.find_by(slug: 'about')
      privacy_first = site.pages.find_by(slug: 'privacy')

      Rake::Task['transdimension:seed_pages'].reenable
      invoke_task

      about_second = site.pages.find_by(slug: 'about')
      privacy_second = site.pages.find_by(slug: 'privacy')

      # Should have exactly 2 pages (no duplicates)
      expect(site.pages.count).to eq(2)

      # Content should be identical
      expect(about_second.body).to eq(about_first.body)
      expect(privacy_second.body).to eq(privacy_first.body)

      # Updated at should not change if content is identical
      expect(about_second.updated_at).to eq(about_first.updated_at)
      expect(privacy_second.updated_at).to eq(privacy_first.updated_at)
    end
  end

  context 'when task fails' do
    it 'raises if site slug not provided' do
      expect { run_task }.to raise_error(ArgumentError, /Usage/)
    end

    it 'raises if site not found' do
      expect { run_task('nonexistent') }.to raise_error(ArgumentError, /not found/)
    end
  end
end
# rubocop:enable Metrics/BlockLength
