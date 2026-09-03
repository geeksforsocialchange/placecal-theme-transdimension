# frozen_string_literal: true

require 'rails_helper'

# WP 2.9 (#3368): the theme owns the footer through core's theme footer slot,
# and the listing pages carry TD's pink intro panel through the hero standfirst.
RSpec.describe 'Trans Dimension footer', type: :request do
  let(:site) do
    create(:site,
           slug: 'transdimension',
           theme: 'transdimension',
           url: 'https://transdimension.lvh.me',
           contact_email: 'hello@transdimension.uk')
  end

  before do
    site.neighbourhoods << create(:riverside_ward)
    get 'http://transdimension.lvh.me/'
  end

  it 'renders the theme footer instead of core\'s' do
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('td-footer')
    expect(response.body).not_to include('footer__inner')
  end

  it 'carries the social heading' do
    expect(response.body).to include('Follow us out there')
  end

  it 'carries the Gendered Intelligence charity number' do
    expect(response.body).to include('Registered Charity in England and Wales No. 1182558')
  end

  it 'lists the About page and the Join us link' do
    expect(response.body).to include('href="/about"')
    expect(response.body).to include('href="/get-in-touch"')
  end

  it 'keeps a log-in link for site admins' do
    expect(response.body).to include('href="/users/sign_in"')
  end

  it 'puts the intro standfirst on the events listing' do
    get 'http://transdimension.lvh.me/events'
    expect(response.body).to include('class="hero__standfirst"')
    expect(response.body).to include('Upcoming events &amp; activities for you.')
  end
end
