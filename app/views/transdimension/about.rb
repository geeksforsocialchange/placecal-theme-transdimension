# frozen_string_literal: true

# The About page (#3368 WP 3.12), a port of the Elm site's About.elm and of the
# body the withdrawn seed task used to assemble.
#
# The markdown pipeline, the per-file cache and the `page page--about` wrapper
# are core's (Views::ThemeContentPage); what is this theme's is the content
# root, the copy keys and the shape of the body.
#
# The body needs more than headings and blocks, so it overrides #page_body, the
# escape hatch core's page documents. Three things about it are About.elm's and
# app/tailwind/pages.css selects on all three: the site description opens the
# page as the pink intro panel (`.page--about .markdown-content > p:first-child`,
# so it has to be the first child of the content column), each markdown block
# sets in two columns inside a measure wider than the headings' (`.about-body`),
# and the two maker sections sit under one shared heading.
class Transdimension::Views::About < Views::ThemeContentPage
  content_root Transdimension::Engine.root.join('content')
  slug         'about'
  title        'transdimension.about.title'
  description  'transdimension.site.description'

  private

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

  # Each markdown block needs an element of its own to flow in. The headings
  # stay direct children of the markdown column, at the measure and the sizes
  # every static page uses.
  def body_columns(relative_path)
    div(class: 'about-body') { markdown(relative_path) }
  end
end
