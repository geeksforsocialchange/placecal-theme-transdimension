# frozen_string_literal: true

require 'rails_helper'

# WP 3.10 (#3368): the theme ships transdimension.uk's own favicons, touch
# icon, Safari mask icon, manifest icons and share image.
#
# Core covers the icon DSL end to end in
# spec/requests/extensions/theme_slots_spec.rb, with the same fixture values,
# so what is left here is what belongs to this theme: that every asset it names
# is actually shipped and served, that the share image is declared at its real
# size (core's fixture says 675), and the brand mask colour.
RSpec.describe 'Trans Dimension icons', type: :request do
  let(:site) do
    create(:site, slug: 'transdimension', theme: 'transdimension', url: 'https://transdimension.lvh.me')
  end

  before do
    site.neighbourhoods << create(:riverside_ward)
    get 'http://transdimension.lvh.me/'
  end

  def head_html
    response.body[%r{<head>.*?</head>}m]
  end

  it 'serves every icon and share image it links' do
    head = head_html
    get 'http://transdimension.lvh.me/manifest.webmanifest'
    # parsed_body leaves an application/manifest+json body as a String
    manifest_srcs = JSON.parse(response.body).fetch('icons').pluck('src') # rubocop:disable Rails/ResponseParsedBody

    srcs = manifest_srcs +
           head.scan(%r{href="([^"]*/assets/transdimension/favicons/[^"]+)"}).flatten +
           [head[/<meta property="og:image" content="([^"]+)">/, 1]]

    expect(srcs.length).to eq(7)
    srcs.each do |src|
      get src
      expect(response).to have_http_status(:ok), "expected #{src} to resolve"
    end
  end

  it 'declares the share image at the size the artwork really is' do
    expect(head_html).to include('<meta property="og:image:width" content="1200">')
    expect(head_html).to include('<meta property="og:image:height" content="630">')
  end

  it 'links the Safari mask icon with the brand pink' do
    expect(head_html).to match(
      %r{<link rel="mask-icon" href="[^"]*/assets/transdimension/favicons/safari-pinned-tab-[0-9a-f]+\.svg" color="#FF7AA7">}
    )
  end
end
