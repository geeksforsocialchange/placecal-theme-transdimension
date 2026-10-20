# frozen_string_literal: true

# The About page, laid out as About.elm: an intro box, then the accessibility,
# makers and PlaceCal sections, each under a small floating label.
class Transdimension::Views::About < Views::ThemeContentPage
  content_root Transdimension::Engine.root.join('content')
  slug         'about'
  title        'transdimension.about.title'
  description  'transdimension.site.description'

  MAKERS = [
    { key: 'gfsc', logo: 'about_gfsc_white.svg', url: 'transdimension.about.gfsc_url', body: 'about/makers/gfsc.md' },
    { key: 'gi', logo: 'GI_white.svg', url: 'transdimension.external.gendered_intelligence_home',
      body: 'about/makers/gi.md' }
  ].freeze

  def view_template
    content_for(:title) { page_title }
    content_for(:description) { page_description }

    div(class: 'container-public py-8 page page--about', data: { page_slug: page_slug }) do
      h1(class: 'h1') { page_title }
      render_intro
      render_accessibility
      render_makers
      render_placecal
    end
  end

  private

  def render_intro
    div(class: 'about-box about-intro') do
      div(class: 'about-panel') { p(class: 'about-lead') { t('transdimension.site.description') } }
      body_columns('about/main.md')
    end
  end

  def render_accessibility
    section(class: 'about-box about-accessibility') do
      h2(class: 'td-floating-title about-label') { t('transdimension.about.accessibility') }
      div(class: 'about-panel') { p(class: 'about-lead') { t('transdimension.about.accessibility_lead') } }
      body_columns('about/accessibility.md')
    end
  end

  def render_makers
    section(class: 'about-makers') do
      h2(class: 'td-floating-title about-label') { t('transdimension.about.makers') }
      MAKERS.each { |maker| render_maker(**maker) }
    end
  end

  def render_maker(key:, logo:, url:, body:)
    div(class: 'about-maker') do
      h3(class: 'about-maker__name') do
        image_tag("transdimension/#{logo}", alt: t("transdimension.about.#{key}"), class: 'about-maker__logo')
      end
      div(class: 'about-maker__body') { markdown(body) }
      p(class: 'about-maker__more') do
        a(href: t(url), class: 'with-no-sass td-button td-button--white') { t('transdimension.about.find_out_more') }
      end
    end
  end

  def render_placecal
    section(class: 'about-box about-placecal') do
      h2(class: 'td-floating-title about-label') { t('transdimension.about.placecal') }
      div(class: 'about-panel') do
        image_tag('transdimension/about_placecal.svg', alt: t('transdimension.about.placecal_logo_alt'),
                                                       class: 'about-placecal__logo')
      end
      body_columns('about/placecal.md')
    end
  end

  def body_columns(relative_path)
    div(class: 'about-body') { markdown(relative_path) }
  end
end
