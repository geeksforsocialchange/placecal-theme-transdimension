# frozen_string_literal: true

require 'rails_helper'

# WP 2.4 (#3368): the per-route page styling is CSS in the built theme
# stylesheet, so what a request can check is that a themed page still renders
# and still links that stylesheet.
RSpec.describe 'Trans Dimension page templates', type: :request do
  let(:site) do
    create(:site, slug: 'transdimension', theme: 'transdimension', url: 'https://transdimension.lvh.me')
  end

  before do
    site.neighbourhoods << create(:riverside_ward)
  end

  it 'renders the events index on the theme stylesheet' do
    get 'http://transdimension.lvh.me/events'

    expect(response).to have_http_status(:ok)
    expect(response.body).to match(%r{<link rel="stylesheet" href="/assets/transdimension/theme-[0-9a-f]+\.css"})
  end
end
