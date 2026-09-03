# frozen_string_literal: true

require 'rails_helper'

# The theme's own static pages (#3368 WP 3.12). About and Privacy are views in
# this engine registered with `theme.page`, not rows in the host database, so
# what a request checks is that core serves the registered slug and that the
# markup app/tailwind/pages.css selects on is still there.
RSpec.describe 'Trans Dimension theme pages', type: :request do
  let(:site) { create(:site, slug: 'td-test', theme: 'transdimension', url: 'https://td-test.lvh.me') }

  before { site }

  describe 'GET /about' do
    before { get 'http://td-test.lvh.me/about' }

    it 'returns 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders the page wrapper the theme CSS selects on' do
      wrapper = response.parsed_body.at_css('.page.page--about')

      expect(wrapper).to be_present
      expect(wrapper['data-page-slug']).to eq('about')
      expect(wrapper.at_css('.markdown-content')).to be_present
    end

    it 'opens with the site description as the intro paragraph' do
      first_paragraph = response.parsed_body.at_css('.markdown-content > p')

      expect(first_paragraph.text).to eq(I18n.t('transdimension.site.description'))
    end

    it 'renders every About section in About.elm order' do
      headings = response.parsed_body.css('.markdown-content h2, .markdown-content h3').map(&:text)

      expect(headings).to eq(
        [
          I18n.t('transdimension.about.accessibility'),
          I18n.t('transdimension.about.makers'),
          I18n.t('transdimension.about.gi'),
          I18n.t('transdimension.about.gfsc'),
          I18n.t('transdimension.about.placecal')
        ]
      )
    end

    it 'renders the markdown content of each section' do
      body = response.body

      expect(body).to include('We see and experience the barriers')
      expect(body).to include('As an event listings site')
      expect(body).to include('Gendered Intelligence is a registered charity')
      expect(body).to include('research and development studio based in Manchester')
      expect(body).to include('PlaceCal is a package of software and training')
    end
  end

  describe 'GET /privacy' do
    before { get 'http://td-test.lvh.me/privacy' }

    it 'returns 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders the theme page wrapper rather than core markdown chrome' do
      wrapper = response.parsed_body.at_css('.page.page--privacy')

      expect(wrapper).to be_present
      expect(wrapper['data-page-slug']).to eq('privacy')
      expect(wrapper.at_css('h1').text).to eq(I18n.t('transdimension.privacy.title'))
    end

    it 'renders the Trans Dimension privacy policy' do
      expect(response.parsed_body.at_css('.markdown-content > p').text)
        .to eq(I18n.t('transdimension.privacy.subtitle'))
      expect(response.body).to include('This page explains how we collect information')
    end
  end

  describe 'the derived site navigation' do
    before { get 'http://td-test.lvh.me/about' }

    it 'lists About' do
      link = response.parsed_body.at_css('header nav a[href="/about"]')

      expect(link).to be_present
      expect(link.text.strip).to eq(I18n.t('transdimension.nav.about'))
    end

    it 'does not list Privacy, which the footer carries instead' do
      expect(response.parsed_body.css('header nav a[href="/privacy"]')).to be_empty
    end
  end

  describe 'GET /sitemap/pages.xml' do
    it 'lists both registered pages' do
      get 'http://td-test.lvh.me/sitemap/pages.xml'

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('https://td-test.lvh.me/about')
      expect(response.body).to include('https://td-test.lvh.me/privacy')
    end
  end
end
