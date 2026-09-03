# frozen_string_literal: true

# The single latest article on the homepage, ported from viewNewsArticle in
# src/Theme/Page/News.elm: image beside a title, a byline and date, and a
# truncated body, with the "Read the rest" button floating on the section's
# bottom edge.
class Transdimension::Components::NewsCard < Components::Base
  register_value_helper :article_summary_text

  # No reader: `article` is also the Phlex element method.
  prop :article, _Interface(:title, :published_at)

  def view_template
    article(class: 'td-news') do
      render_image
      div(class: 'td-news__info') do
        h3(class: 'td-news__title') do
          link_to news_article.title, news_path(news_article), class: 'with-no-sass td-news__link'
        end
        render_meta
        p(class: 'td-news__summary') { article_summary_text(news_article) }
      end
    end
    div(class: 'td-button-floating') do
      link_to t('transdimension.home.news_read_more'), news_path(news_article),
              class: 'with-no-sass td-button td-button--pink-on-light'
    end
  end

  private

  def news_article
    @article
  end

  def render_image
    return if news_article.article_image.blank?

    image_tag(news_article.article_image.url, class: 'td-news__image', alt: '')
  end

  def render_meta
    p(class: 'td-news__meta') do
      span(class: 'td-news__author') { authors } if authors.present?
      time(datetime: news_article.published_at.to_date.iso8601) { published_on }
    end
  end

  def authors
    @authors ||= news_article.partners.map(&:name).join(', ')
  end

  # Elm's TransDate.humanDateFromPosix: "14th January 2025".
  def published_on
    date = news_article.published_at.to_date
    I18n.l(date, format: "#{date.day.ordinalize} %B %Y")
  end
end
