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

  # About and Privacy render inside core's Views::ThemeContentPage, and
  # app/tailwind/theme.css scans this engine only, so the utilities that wrapper
  # uses are named by hand in the `@source inline` list at the top of the file.
  # A hand-maintained list against a file in another repository is nothing until
  # something couples the two: if core's wrapper gains a utility, the class is
  # simply missing from the build and the page renders unstyled. So take the
  # classes off the rendered page and require a rule for each, in the committed
  # theme build or in core's public build, which the layout links alongside it.
  describe "the utilities core's shared content page wrapper emits" do
    let(:built_css) do
      [Transdimension::Engine.root.join('app/assets/builds/transdimension/theme.css'),
       Rails.root.join('app/assets/builds/public_tailwind.css')].select(&:exist?).map(&:read).join("\n")
    end

    # Tailwind escapes the parentheses of an arbitrary-value utility, and the
    # negative lookahead stops `.page` matching `.page--about`.
    def rule_for?(css, klass)
      css.match?(/\.#{Regexp.escape(klass.gsub(/[()]/) { |c| "\\#{c}" })}(?![\w-])/)
    end

    { 'About' => ['/about', 'about'], 'Privacy' => ['/privacy', 'privacy'] }.each do |page, (path, slug)|
      it "ships a rule for every class the #{page} wrapper carries" do
        get "http://transdimension.lvh.me#{path}"

        expect(response).to have_http_status(:ok)

        wrapper = response.parsed_body.at_css('[data-page-slug]')
        expect(wrapper).to be_present

        # The wrapper and its own children, not the page body: this is core's
        # markup. `page--<slug>` is a per-page hook a theme styles only if it
        # wants to, so it is the one class allowed to carry no rule.
        classes = [wrapper, *wrapper.element_children].flat_map { |el| el['class'].to_s.split }.uniq
        missing = (classes - ["page--#{slug}"]).reject { |klass| rule_for?(built_css, klass) }

        expect(missing).to be_empty, "no CSS rule ships for: #{missing.join(', ')}"
      end
    end
  end
end
