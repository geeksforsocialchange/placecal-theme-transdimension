# frozen_string_literal: true

require 'rails_helper'

# WP 2.1 (#3368): the engine skeleton registers the transdimension theme and
# core renders it, with no core changes.
RSpec.describe 'Trans Dimension theme', type: :request do
  it 'registers the theme' do
    expect(PlaceCal::Extensions.theme_names).to include('transdimension')
  end

  it 'uses the day strip event filter (D22)' do
    theme = PlaceCal::Extensions.fetch_theme('transdimension')
    expect(theme.event_filter_style).to eq(:day_strip)
  end

  it 'points the nav CTA at the Donate URL' do
    theme = PlaceCal::Extensions.fetch_theme('transdimension')

    expect(theme.nav_cta).to eq(
      label_key: 'transdimension.header.donate',
      url: 'https://donorbox.org/the-trans-dimension'
    )
  end

  it 'keeps the Join link out of the nav (the footer carries it)' do
    expect(PlaceCal::Extensions.fetch_theme('transdimension').nav_join?).to be(false)
  end

  it 'autoloads the engine Phlex namespaces' do
    expect(Transdimension::Views::Home.superclass).to eq(Views::Base)
    expect(Transdimension::Components::Footer.superclass).to eq(Components::Base)
  end

  it 'loads the engine locale file' do
    expect(I18n.t('transdimension.site.title')).to eq('The Trans Dimension')
  end

  context 'with a site on the theme' do
    let(:site) do
      create(:site, slug: 'transdimension', theme: 'transdimension', url: 'https://transdimension.lvh.me')
    end

    before do
      site.neighbourhoods << create(:riverside_ward)
    end

    it 'renders the theme homepage' do
      get 'http://transdimension.lvh.me/'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('The Trans Dimension')
    end

    it 'links the built theme stylesheet' do
      get 'http://transdimension.lvh.me/'
      expect(response.body).to match(%r{<link rel="stylesheet" href="/assets/transdimension/theme-[0-9a-f]+\.css"})
    end

    it 'serves the built theme stylesheet' do
      path = ActionController::Base.helpers.asset_path('transdimension/theme.css')
      get path
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('text/css')
    end
  end
end
