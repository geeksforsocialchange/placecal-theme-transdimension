# frozen_string_literal: true

# The Trans Dimension homepage (#3368 WP 2.3), a port of the Elm site's
# src/Theme/Page/Index.elm.
#
# Three stacked sections, each a positioned box with an illustration painted
# behind it by a ::before (and, for the news section, an ::after) in
# app/tailwind/home.css. The engine owns the whole page: the homepage is the one
# page that IS an extension view by design, so the event and news cards are the
# theme's own components rather than core's.
#
# Data comes from core's query objects. The controller passes only the site, so
# the region choice is read off the controller's own helper methods, the same
# ones core's Views::Sites::Default is handed as props.
class Transdimension::Views::Home < Views::Base
  prop :site, Site, reader: :private

  # Index.elm shows the next 8 upcoming events across the two columns.
  MAX_EVENTS = 8

  def view_template
    content_for(:title) { t('transdimension.home.meta_title') }
    content_for(:description) { t('transdimension.home.meta_description') }

    div(class: 'td-home') do
      render_intro
      render_events
      render_news
    end
  end

  private

  def render_intro
    section(class: 'td-section td-section--intro') do
      h1(class: 'td-home__logo') do
        image_tag('transdimension/tdd_logo_with_strapline.svg',
                  class: 'td-home__logo-image',
                  alt: t('transdimension.home.logo_alt'))
      end
      h2(class: 'td-section__subtitle') { t('transdimension.home.intro_title') }
      p(class: 'td-section__text') { t('transdimension.home.intro_message') }
      p(class: 'td-button-floating') do
        link_to t('transdimension.home.intro_button'), events_path,
                class: 'with-no-sass td-button td-button--white'
      end
    end
  end

  def render_events
    section(class: 'td-section td-section--events') do
      h2(class: 'td-floating-title') { t('transdimension.home.events_header') }
      render_region_filter
      div(class: 'td-events') { render_event_list }
      p(class: 'td-button-floating') do
        link_to t('transdimension.home.events_button'), events_path(**region_param),
                class: 'with-no-sass td-button td-button--pink'
      end
    end
  end

  # Only sites with more than one Partnership tag offer the filter (#3368 D7).
  def render_region_filter
    return if region_tags.size < 2

    RegionFilter(tags: region_tags, selected: current_region)
  end

  def render_event_list
    if events.any?
      ul(class: 'td-events__list') do
        events.each { |event| render Transdimension::Components::EventCard.new(event: event) }
      end
    else
      p(class: 'td-events__empty') { t('transdimension.home.events_empty') }
    end
  end

  def render_news
    section(class: 'td-section td-section--news') do
      h2(class: 'td-floating-title') { t('transdimension.home.news_header') }
      render Transdimension::Components::NewsCard.new(article: latest_article) if latest_article
      p(class: 'td-button-floating td-button-floating--news') do
        link_to t('transdimension.home.news_button'), news_index_path,
                class: 'with-no-sass td-button td-button--dark'
      end
    end
  end

  def events
    @events ||= EventsQuery
                .new(site: site)
                .call(period: 'future', tag_id: current_region&.id)
                .values.flatten.first(MAX_EVENTS)
  end

  def latest_article
    return @latest_article if defined?(@latest_article)

    @latest_article = Article.for_site(site).published.by_publish_date.first
  end

  def region_tags
    @region_tags ||= view_context.region_tags
  end

  def current_region
    return @current_region if defined?(@current_region)

    @current_region = view_context.current_region
  end

  def region_param
    current_region ? { region: current_region.slug } : {}
  end
end
