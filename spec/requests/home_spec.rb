# frozen_string_literal: true

require 'rails_helper'

# WP 2.3 (#3368): the Trans Dimension homepage, rendered by the engine's own
# Phlex view from core's query objects.
RSpec.describe 'Trans Dimension homepage', type: :request do
  let(:london) { create(:partnership, name: 'London') }
  let(:manchester) { create(:partnership, name: 'Manchester') }

  let(:site) do
    create(:site, slug: 'transdimension', theme: 'transdimension',
                  url: 'https://transdimension.lvh.me')
  end

  let(:london_partner) { create(:partner, name: 'London Trans Meet Up', tags: [london]) }
  let(:manchester_partner) { create(:partner, name: 'Manchester Trans Meet Up', tags: [manchester]) }

  before do
    site.tags << london
    site.tags << manchester

    create(:event, summary: 'London Trans+ Meet Up', organiser: london_partner,
                   dtstart: 3.days.from_now, dtend: 3.days.from_now + 2.hours)
    create(:event, summary: 'Manchester Trans+ Meet Up', organiser: manchester_partner,
                   dtstart: 4.days.from_now, dtend: 4.days.from_now + 2.hours)

    create(:article, title: 'Greater Manchester Trans Organisers Fund',
                     is_draft: false, published_at: 1.day.ago, tags: [london])
  end

  it 'renders the intro, the events and the latest article' do
    get 'http://transdimension.lvh.me/'

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Trusted, accessible, trans-friendly spaces. Always expanding.')
    expect(response.body).to include('London Trans+ Meet Up')
    expect(response.body).to include('Greater Manchester Trans Organisers Fund')
  end

  it "draws the events with core's card, the one the listing page uses" do
    get 'http://transdimension.lvh.me/'

    expect(response.body).to include('event event--list')
    expect(response.body).not_to include('td-event__title')
  end

  it 'offers the region filter with both partnership tags' do
    get 'http://transdimension.lvh.me/'

    expect(response.body).to include('region-filter')
    expect(response.body).to include('?region=london')
    expect(response.body).to include('?region=manchester')
  end

  it 'filters the events by the region in the query string' do
    get 'http://transdimension.lvh.me/?region=manchester'

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Manchester Trans+ Meet Up')
    expect(response.body).not_to include('London Trans+ Meet Up')
  end

  context 'when the site has one partnership tag' do
    let(:single_tag_site) do
      create(:site, slug: 'onetag', theme: 'transdimension',
                    url: 'https://onetag.lvh.me', tags: [london])
    end

    it 'shows no region filter' do
      single_tag_site
      get 'http://onetag.lvh.me/'

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('region-filter')
    end
  end
end
