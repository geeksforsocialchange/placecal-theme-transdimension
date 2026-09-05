# frozen_string_literal: true

require 'rails_helper'

# Every page a Trans Dimension visitor can reach, checked with axe-core the way
# core checks its own directory (spec/system/directory/accessibility_spec.rb).
# The theme repaints core's markup wholesale, so contrast, link names and
# landmark structure are this engine's to get right even where the elements come
# from core.
RSpec.describe 'Trans Dimension accessibility', type: :system do
  # heading-order is the one rule skipped, and only on the article page, where
  # the single remaining offender is core's markup and unreachable from a theme:
  # app/views/news/show.rb renders the byline as
  # <h3 class="article__author"> directly under the article h1, so the sequence
  # goes h1 to h3 with no h2 between. Core is turning that h3 into a paragraph
  # in a parallel work package; drop this skip once that lands.
  #
  # Every other page is checked with nothing skipped, so a heading a view or
  # component in this engine emits out of order has to fail here.
  CORE_OWNED_RULES = [:'heading-order'].freeze

  def expect_axe_clean
    expect(page).to be_axe_clean
  end

  let(:london) { create(:partnership, name: 'London') }
  let(:manchester) { create(:partnership, name: 'Manchester') }

  let(:site) do
    create(:site, slug: 'transdimension', theme: 'transdimension',
                  url: 'https://transdimension.lvh.me')
  end

  let(:partner) { create(:partner, name: 'London Trans Meet Up', tags: [london]) }

  let(:event) do
    create(:event, summary: 'London Trans+ Meet Up', organiser: partner,
                   dtstart: 3.days.from_now, dtend: 3.days.from_now + 2.hours)
  end

  let(:article) do
    create(:article, title: 'Greater Manchester Trans Organisers Fund',
                     is_draft: false, published_at: 1.day.ago, tags: [london])
  end

  before do
    site.tags << london
    site.tags << manchester
    event
    article
  end

  # The site is resolved from the request host, so every visit goes to the
  # themed host on Capybara's port rather than Capybara.app_host.
  def visit_themed(path)
    visit "http://transdimension.lvh.me:#{Capybara.current_session.server.port}#{path}"
  end

  {
    'the homepage' => '/',
    'the events listing' => '/events',
    'the events listing filtered by region' => '/events?region=london',
    'the partners listing' => '/partners',
    'the news listing' => '/news',
    "the theme's About page" => '/about',
    "the theme's Privacy page" => '/privacy',
    'the Get in touch page' => '/get-in-touch'
  }.each do |description, path|
    it "has no accessibility violations on #{description}" do
      visit_themed(path)

      expect_axe_clean
    end
  end

  it 'has no accessibility violations on a partner page' do
    visit_themed("/partners/#{partner.to_param}")

    expect_axe_clean
  end

  it 'has no accessibility violations on an event page' do
    visit_themed("/events/#{event.to_param}")

    expect_axe_clean
  end

  it 'has no accessibility violations on an article' do
    visit_themed("/news/#{article.to_param}")

    expect(page).to be_axe_clean.skipping(*CORE_OWNED_RULES)
  end
end
