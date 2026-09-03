# frozen_string_literal: true

require 'rails_helper'

# Renders the theme's static page views on their own (#3368 WP 3.12), so the
# markup is covered without depending on core's page routing.
RSpec.describe 'Trans Dimension static page views', type: :phlex do
  let(:site) { create(:site, slug: 'td-test', theme: 'transdimension', url: 'https://td-test.lvh.me') }

  describe Transdimension::Views::About do
    before { render_inline(described_class.new(site: site)) }

    it 'wraps the page in the classes the theme CSS selects on' do
      wrapper = page.find('.page.page--about')

      expect(wrapper[:'data-page-slug']).to eq('about')
      expect(wrapper).to have_css('.markdown-content')
    end

    it 'titles the page from the locale file' do
      expect(page).to have_css('h1', text: I18n.t('transdimension.about.title'))
    end

    it 'opens the content column with the site description' do
      expect(page.first('.markdown-content > p').text)
        .to eq(I18n.t('transdimension.site.description'))
    end

    it 'renders the sections in About.elm order' do
      headings = page.all('.markdown-content h2, .markdown-content h3').map(&:text)

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

    it 'renders the markdown of every content file' do
      text = page.find('.markdown-content').text

      expect(text).to include('We see and experience the barriers')
      expect(text).to include('As an event listings site')
      expect(text).to include('Gendered Intelligence is a registered charity')
      expect(text).to include('research and development studio based in Manchester')
      expect(text).to include('PlaceCal is a package of software and training')
    end
  end

  describe Transdimension::Views::Privacy do
    before { render_inline(described_class.new(site: site)) }

    it 'wraps the page in the classes the theme CSS selects on' do
      wrapper = page.find('.page.page--privacy')

      expect(wrapper[:'data-page-slug']).to eq('privacy')
      expect(wrapper).to have_css('h1', text: I18n.t('transdimension.privacy.title'))
    end

    it 'opens with the subtitle and renders the policy' do
      expect(page.first('.markdown-content > p').text)
        .to eq(I18n.t('transdimension.privacy.subtitle'))
      expect(page.find('.markdown-content').text).to include('This page explains how we collect information')
    end

    it 'names the analytics and font services the site actually uses' do
      text = page.find('.markdown-content').text

      expect(text).to include('Matomo', 'stats.gfsc.community', 'Adobe Typekit')
      expect(text).not_to include('Plausible')
    end
  end

  describe 'markdown caching' do
    it 'parses a content file once and reuses the render' do
      # Prime the memo, then watch: a second render of the same file must not
      # go back to Kramdown.
      render_inline(Transdimension::Views::Privacy.new(site: site))
      allow(Kramdown::Document).to receive(:new).and_call_original

      render_inline(Transdimension::Views::Privacy.new(site: site))

      expect(Kramdown::Document).not_to have_received(:new)
    end
  end
end
