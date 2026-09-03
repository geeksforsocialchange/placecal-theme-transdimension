# frozen_string_literal: true

require 'rails_helper'

# WP 3.10 (#3368): the theme ships transdimension.uk's own favicons, touch
# icon, Safari mask icon, manifest icons and share image.
RSpec.describe 'Trans Dimension icons', type: :request do
  let(:site) do
    create(:site, slug: 'transdimension', theme: 'transdimension', url: 'https://transdimension.lvh.me')
  end

  before do
    site.neighbourhoods << create(:riverside_ward)
  end

  def head_html
    response.body[%r{<head>.*?</head>}m]
  end

  describe 'the head' do
    before { get 'http://transdimension.lvh.me/' }

    it 'responds' do
      expect(response).to have_http_status(:ok)
    end

    it 'links the two favicons' do
      expect(head_html).to match(%r{<link rel="icon" type="image/png" sizes="32x32" href="[^"]*/assets/transdimension/favicons/favicon-32x32-[0-9a-f]+\.png">})
      expect(head_html).to match(%r{<link rel="icon" type="image/png" sizes="16x16" href="[^"]*/assets/transdimension/favicons/favicon-16x16-[0-9a-f]+\.png">})
    end

    it 'links the apple touch icon' do
      expect(head_html).to match(%r{<link rel="apple-touch-icon" sizes="180x180" href="[^"]*/assets/transdimension/favicons/apple-touch-icon-[0-9a-f]+\.png">})
    end

    it 'links the Safari mask icon with the brand pink' do
      expect(head_html).to match(%r{<link rel="mask-icon" href="[^"]*/assets/transdimension/favicons/safari-pinned-tab-[0-9a-f]+\.svg" color="#FF7AA7">})
    end

    it 'drops core favicon and touch icon' do
      expect(head_html).not_to match(%r{href="[^"]*/assets/favicon-[0-9a-f]+\.png"})
      expect(head_html).not_to include('rel="apple-touch-icon" href=')
    end

    it 'emits the theme colour meta' do
      expect(head_html).to include('<meta name="theme-color" content="#ff7aa7">')
    end

    it 'points og:image at the theme share image at its real size' do
      expect(head_html).to match(%r{<meta property="og:image" content="[^"]*/assets/transdimension/og-share-[0-9a-f]+\.png">})
      expect(head_html).to include('<meta property="og:image:width" content="556">')
      expect(head_html).to include('<meta property="og:image:height" content="320">')
    end

    it 'serves every icon it links' do
      hrefs = head_html.scan(%r{href="(http://transdimension\.lvh\.me/assets/transdimension/favicons/[^"]+)"}).flatten
      expect(hrefs.length).to eq(4)

      hrefs.each do |href|
        get href
        expect(response).to have_http_status(:ok), "expected #{href} to resolve"
      end
    end

    it 'serves the share image' do
      src = head_html[/<meta property="og:image" content="([^"]+)">/, 1]

      get src
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'the web manifest' do
    subject(:manifest) do
      get 'http://transdimension.lvh.me/manifest.webmanifest'
      # parsed_body leaves an application/manifest+json body as a String
      JSON.parse(response.body) # rubocop:disable Rails/ResponseParsedBody
    end

    it 'uses the theme android icons' do
      icons = manifest['icons']
      expect(icons.pluck('sizes')).to eq(%w[192x192 512x512])
      expect(icons[0]['src']).to match(%r{/assets/transdimension/favicons/android-chrome-192x192-[0-9a-f]+\.png})
      expect(icons[1]['src']).to match(%r{/assets/transdimension/favicons/android-chrome-512x512-[0-9a-f]+\.png})
      expect(icons.pluck('type')).to all(eq('image/png'))
    end

    it 'uses the theme colours' do
      expect(manifest['background_color']).to eq('#040f39')
      expect(manifest['theme_color']).to eq('#ff7aa7')
    end

    it 'serves every manifest icon' do
      manifest['icons'].each do |icon|
        get icon['src']
        expect(response).to have_http_status(:ok), "expected #{icon['src']} to resolve"
      end
    end
  end
end
