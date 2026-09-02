# frozen_string_literal: true

require 'rails_helper'

describe 'Pages requests' do
  let(:site) { create(:site, slug: 'td-test', theme: 'transdimension', url: 'https://td-test.lvh.me') }

  before do
    Transdimension::SeedPages.new(site.slug).call
  end

  describe 'GET /about' do
    it 'returns 200 and displays About page content' do
      get '/about', headers: { 'Host' => 'td-test.lvh.me' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('We see and experience the barriers')
    end
  end
end
