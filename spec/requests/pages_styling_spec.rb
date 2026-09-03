# frozen_string_literal: true

require 'rails_helper'

# WP 2.4 (#3368): the per-route page styling is CSS in the built theme
# stylesheet, so what a request can check is that a themed page still renders
# and still links that stylesheet.
#
# app/tailwind/pages.css also hangs its rules off markup core does not treat as
# public API: a turbo frame id, two BEM-ish class names from core's components,
# and the schema.org `vocab` wrapper on the news article. A rename in core would
# silently unstyle a Trans Dimension page, so each hook is asserted here.
RSpec.describe 'Trans Dimension page templates', type: :request do
  let(:london) { create(:partnership, name: 'London') }

  let(:site) do
    create(:site, slug: 'transdimension', theme: 'transdimension', url: 'https://transdimension.lvh.me')
  end

  # The Trans Dimension is a tag-scoped site: it spans cities and picks its
  # partners by Partnership tag alone, with no neighbourhoods (#3368 D7/D24).
  before do
    site.tags << london
  end

  it 'renders the events index on the theme stylesheet' do
    get 'http://transdimension.lvh.me/events'

    expect(response).to have_http_status(:ok)
    expect(response.body).to match(%r{<link rel="stylesheet" href="/assets/transdimension/theme-[0-9a-f]+\.css"})
  end

  describe 'the markup hooks app/tailwind/pages.css selects on' do
    let(:partner) { create(:partner, name: 'Riverside Trans Meet Up', tags: [london]) }

    it 'keeps #events-browser on the events index' do
      get 'http://transdimension.lvh.me/events'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.at_css('#events-browser')).to be_present
    end

    it 'keeps .articles__article-card on the news index' do
      create(:article, title: 'Greater Manchester Trans Organisers Fund',
                       is_draft: false, published_at: 1.day.ago, tags: [london])

      get 'http://transdimension.lvh.me/news'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.at_css('.articles__article-card')).to be_present
    end

    it 'keeps main > div[vocab] on a news article' do
      article = create(:article, title: 'Greater Manchester Trans Organisers Fund',
                                 is_draft: false, published_at: 1.day.ago, tags: [london])

      get "http://transdimension.lvh.me#{news_path(article)}"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.at_css('main > div[vocab]')).to be_present
    end

    it 'keeps .partners .preview__details on the partners index' do
      partner

      get 'http://transdimension.lvh.me/partners'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.at_css('.partners .preview__details')).to be_present
    end

    it 'keeps .g--partner .place_info__address on a partner page' do
      get "http://transdimension.lvh.me#{partner_path(partner)}"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.at_css('.g--partner .place_info__address')).to be_present
    end
  end
end
