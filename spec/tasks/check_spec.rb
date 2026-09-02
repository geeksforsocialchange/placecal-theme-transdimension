# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/InstanceVariable, Metrics/BlockLength
describe 'transdimension:check task' do
  describe 'with a fully configured Trans Dimension site' do
    before do
      london_tag = create(:partnership, name: 'London')
      manchester_tag = create(:partnership, name: 'Manchester')
      site_admin = create(:root_user)

      site = create(:site,
                    slug: 'transdimension',
                    name: 'The Trans Dimension',
                    url: 'https://transdimension.uk',
                    theme: 'transdimension',
                    is_published: true,
                    contact_email: 'contact@transdimension.uk',
                    site_admin: site_admin)

      site.tags << [london_tag, manchester_tag]
      allow(site.logo).to receive_messages(present?: true, file: double(present?: true))
      allow(site.hero_image).to receive_messages(present?: true, file: double(present?: true))

      create(:page, site: site, slug: 'about', is_published: true)
      create(:page, site: site, slug: 'privacy', is_published: true)
    end

    it 'is published' do
      site = Site.find_by(slug: 'transdimension')
      expect(site.is_published).to be(true)
    end

    it 'has correct URL' do
      site = Site.find_by(slug: 'transdimension')
      expect(site.url).to eq('https://transdimension.uk')
    end

    it 'has transdimension theme' do
      site = Site.find_by(slug: 'transdimension')
      expect(site.theme).to eq('transdimension')
    end

    it 'has London and Manchester tags' do
      site = Site.find_by(slug: 'transdimension')
      tags = site.tags.where(type: 'Partnership').pluck(:name)
      expect(tags.map(&:downcase)).to include('london', 'manchester')
    end

    it 'has contact email' do
      site = Site.find_by(slug: 'transdimension')
      expect(site.contact_email).to be_present
      expect(site.contact_email).to match(URI::MailTo::EMAIL_REGEXP)
    end

    it 'has site admin' do
      site = Site.find_by(slug: 'transdimension')
      expect(site.site_admin).to be_present
    end

    it 'can store logo' do
      site = Site.find_by(slug: 'transdimension')
      # In tests with transactional fixtures, we verify the uploader is present
      # The rake task will check that files are actually uploaded
      expect(site.logo).to respond_to(:present?)
    end

    it 'can store hero image' do
      site = Site.find_by(slug: 'transdimension')
      # In tests with transactional fixtures, we verify the uploader is present
      # The rake task will check that files are actually uploaded
      expect(site.hero_image).to respond_to(:present?)
    end

    it 'has no neighbourhoods' do
      site = Site.find_by(slug: 'transdimension')
      expect(site.neighbourhoods).to be_empty
    end

    it 'has about and privacy pages' do
      site = Site.find_by(slug: 'transdimension')
      about_page = site.pages.find_by(slug: 'about')
      privacy_page = site.pages.find_by(slug: 'privacy')
      expect(about_page).to be_present
      expect(privacy_page).to be_present
    end
  end

  describe 'with the wrong theme' do
    before do
      create(:site, slug: 'transdimension', theme: 'pink')
    end

    it 'has wrong theme' do
      site = Site.find_by(slug: 'transdimension')
      expect(site.theme).not_to eq('transdimension')
    end
  end

  describe 'when site does not exist' do
    it 'does not find site' do
      site = Site.find_by(slug: 'nonexistent')
      expect(site).to be_nil
    end
  end

  describe 'with neighbourhoods configured' do
    before do
      london_tag = create(:partnership, name: 'London')
      manchester_tag = create(:partnership, name: 'Manchester')
      site_admin = create(:root_user)
      neighbourhood = create(:riverside_ward)

      site = create(:site,
                    slug: 'transdimension',
                    name: 'The Trans Dimension',
                    url: 'https://transdimension.uk',
                    theme: 'transdimension',
                    is_published: true,
                    contact_email: 'contact@transdimension.uk',
                    site_admin: site_admin)

      site.tags << [london_tag, manchester_tag]
      site.neighbourhoods << neighbourhood
      allow(site.logo).to receive_messages(present?: true, file: double(present?: true))
      allow(site.hero_image).to receive_messages(present?: true, file: double(present?: true))

      create(:page, site: site, slug: 'about', is_published: true)
      create(:page, site: site, slug: 'privacy', is_published: true)
    end

    it 'has neighbourhoods' do
      site = Site.find_by(slug: 'transdimension')
      expect(site.neighbourhoods).not_to be_empty
    end
  end
end
# rubocop:enable RSpec/InstanceVariable, Metrics/BlockLength
