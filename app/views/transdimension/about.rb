# frozen_string_literal: true

# The About page (#3368 WP 3.12), a port of the Elm site's About.elm and of the
# body the withdrawn seed task used to assemble.
#
# The site description opens the page as the pink intro panel: pages.css styles
# `.page--about .markdown-content > p:first-child`, so it has to be the first
# child of the content column. The section headings are copy, so they come from
# the locale file rather than the markdown files.
class Transdimension::Views::About < Transdimension::Views::ContentPage
  private

  def slug
    'about'
  end

  def page_title
    t('transdimension.about.title')
  end

  def page_description
    t('transdimension.site.description')
  end

  def page_body
    p { t('transdimension.site.description') }
    body_columns('about/main.md')

    h2 { t('transdimension.about.accessibility') }
    body_columns('about/accessibility.md')

    render_makers

    h2 { t('transdimension.about.placecal') }
    body_columns('about/placecal.md')
  end

  def render_makers
    h2 { t('transdimension.about.makers') }
    h3 { t('transdimension.about.gi') }
    body_columns('about/makers/gi.md')
    h3 { t('transdimension.about.gfsc') }
    body_columns('about/makers/gfsc.md')
  end

  # About.elm sets the body copy in two columns inside a measure wider than
  # TextHeavyPage's, so each markdown block needs an element of its own to flow
  # in. The headings stay direct children of the markdown column, at the
  # measure and the sizes every static page uses.
  def body_columns(relative_path)
    div(class: 'about-body') { markdown(relative_path) }
  end
end
