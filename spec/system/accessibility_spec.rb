# frozen_string_literal: true

require 'rails_helper'

# Every page a Trans Dimension visitor can reach, checked with axe-core the way
# core checks its own directory (spec/system/directory/accessibility_spec.rb).
# The theme repaints core's markup wholesale, so contrast, link names and
# landmark structure are this engine's to get right even where the elements come
# from core.
RSpec.describe 'Trans Dimension accessibility', type: :system do
  # Nothing is skipped: core's article byline and footer headings, the last
  # two heading-order offenders, are fixed, so a heading a view or component in
  # this engine emits out of order has to fail here.
  def expect_axe_clean
    expect(page).to be_axe_clean
  end

  let(:london) { create(:partnership, name: 'London') }
  let(:manchester) { create(:partnership, name: 'Manchester') }

  let(:site) do
    create(:site, slug: 'transdimension', theme: 'transdimension')
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

  # axe cannot resolve backgrounds past the page's pseudo elements, so it skips this text as needs-review.
  it 'gives text on the mauve fills of the partners listing at least 4.5:1 contrast' do
    visit_themed('/partners')

    colours = page.evaluate_script(<<~JS)
      (() => {
        const badge = getComputedStyle(document.querySelector('.preview__neighbourhood span'));
        const search = document.querySelector('input.filters__search');
        return {
          badge: [badge.color, badge.backgroundColor],
          placeholder: [getComputedStyle(search, '::placeholder').color, getComputedStyle(search).backgroundColor]
        };
      })()
    JS

    expect(colours.transform_values { |pair| contrast(*pair).round(2) })
      .to match('badge' => be >= 4.5, 'placeholder' => be >= 4.5)
  end

  def contrast(foreground, background)
    lighter, darker = [foreground, background].map { |rgb| luminance(rgb) }.sort.reverse
    (lighter + 0.05) / (darker + 0.05)
  end

  def luminance(rgb)
    red, green, blue = rgb.scan(/\d+/).first(3).map do |channel|
      value = channel.to_f / 255
      value <= 0.04045 ? value / 12.92 : ((value + 0.055) / 1.055)**2.4
    end
    (0.2126 * red) + (0.7152 * green) + (0.0722 * blue)
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

    expect_axe_clean
  end
end
