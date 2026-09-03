# frozen_string_literal: true

# Base for the theme's own static pages (#3368 WP 3.12).
#
# Trans Dimension's About and Privacy copy is markdown in this engine's
# content/ directory rather than rows in a database, so the text stays
# reviewable in diffs and ships with the theme. Core serves each page at its
# registered slug and instantiates the view with `new(site:)`.
#
# The markup deliberately repeats what core's page view produced: the
# `page page--<slug>` wrapper, the `data-page-slug` attribute and the
# `.markdown-content` column. app/tailwind/pages.css and illustrations.css
# select on all three.
class Transdimension::Views::ContentPage < Views::Base
  prop :site, ::Site, reader: :private

  CONTENT_DIR = Transdimension::Engine.root.join('content')

  class << self
    # Rendered HTML per markdown file, keyed on the file and its mtime so a
    # content edit in development is picked up without re-parsing every request
    # in production. A superseded entry is left behind rather than evicted,
    # which is bounded by the edits in one dev session. Read and written only
    # through ContentPage, so the two page views share one cache.
    def markdown_html(relative_path)
      path = CONTENT_DIR.join(relative_path)
      (@markdown_cache ||= {})[[relative_path, File.mtime(path)]] ||= render_markdown(path.read)
    end

    private

    def render_markdown(markdown)
      Rails::HTML5::SafeListSanitizer.new.sanitize(Kramdown::Document.new(markdown).to_html)
    end
  end

  def view_template
    content_for(:title) { page_title }
    content_for(:description) { page_description } if page_description

    div(class: "container-public py-8 page page--#{slug}", data: { page_slug: slug }) do
      h1(class: 'h1') { page_title }

      div(class: 'markdown-content max-w-(--width-prose-lg) text-base leading-relaxed') do
        page_body
      end
    end
  end

  private

  # Subclasses supply the slug, the title and the body.
  def slug
    raise NotImplementedError
  end

  def page_title
    raise NotImplementedError
  end

  def page_body
    raise NotImplementedError
  end

  # Meta description; nil leaves the layout's own default in place.
  def page_description
    nil
  end

  # `raw` writes straight to the buffer, so it composes with the headings the
  # views emit around each markdown file.
  def markdown(relative_path)
    raw safe(Transdimension::Views::ContentPage.markdown_html(relative_path))
  end
end
