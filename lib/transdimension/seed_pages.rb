# frozen_string_literal: true

module Transdimension
  # Seeds Trans Dimension static content into PlaceCal Pages.
  class SeedPages
    # Section headings, read from transdimension.about.<key>. The seeded body is
    # markdown, so the headings are copy like any other and belong in the locale
    # file rather than here.
    SECTION_KEYS = %i[accessibility makers placecal gi gfsc].freeze

    def initialize(site_slug)
      @site = Site.find_by(slug: site_slug)
      raise ArgumentError, "Site not found: #{site_slug}" unless @site
    end

    def call
      seed_about_page
      seed_privacy_page
    end

    private

    attr_reader :site

    def seed_about_page
      about_body = build_about_body
      upsert_page(
        slug: 'about',
        title: I18n.t('transdimension.about.title'),
        body: about_body,
        position: 10,
        show_in_nav: true
      )
    end

    def build_about_body
      contents = read_about_contents(Transdimension::Engine.root)
      headings = fetch_section_headings

      [
        about_intro,
        contents[:main],
        "\n\n## #{headings[:accessibility]}\n\n#{contents[:accessibility]}",
        "\n\n## #{headings[:makers]}\n\n### #{headings[:gi]}\n\n#{contents[:gi]}",
        "### #{headings[:gfsc]}\n\n#{contents[:gfsc]}",
        "\n\n## #{headings[:placecal]}\n\n#{contents[:placecal]}"
      ].join
    end

    # About.elm opens with the site description in the pink intro panel
    # (the theme styles the page's first paragraph).
    def about_intro
      "#{I18n.t('transdimension.site.description')}\n\n"
    end

    def read_about_contents(engine_root)
      {
        main: read_content_file(engine_root.join('content/about/main.md')),
        accessibility: read_content_file(engine_root.join('content/about/accessibility.md')),
        gi: read_content_file(engine_root.join('content/about/makers/gi.md')),
        gfsc: read_content_file(engine_root.join('content/about/makers/gfsc.md')),
        placecal: read_content_file(engine_root.join('content/about/placecal.md'))
      }
    end

    def fetch_section_headings
      SECTION_KEYS.index_with { |key| section_heading(key) }
    end

    def seed_privacy_page
      engine_root = Transdimension::Engine.root
      privacy_content = read_content_file(engine_root.join('content/privacy.md'))

      upsert_page(
        slug: 'privacy',
        title: I18n.t('transdimension.privacy.title'),
        body: "#{I18n.t('transdimension.privacy.subtitle')}\n\n#{privacy_content}",
        position: 20,
        show_in_nav: false
      )
    end

    # Existing pages may have been edited in the admin, and the seed must not
    # silently throw that away: a page whose stored title or body differs from
    # the seed is left alone unless FORCE=1. is_published is only ever set when
    # the page is created, so unpublishing a page in the admin sticks.
    def upsert_page(slug:, **attrs)
      page = site.pages.find_by(slug:)
      return create_page(slug, attrs) if page.nil?

      if edited_in_admin?(page, attrs) && !force?
        report "skipped #{slug}: edited in admin, run with FORCE=1 to overwrite"
        return
      end

      update_page(page, slug, attrs)
    end

    def create_page(slug, attrs)
      site.pages.create!(slug:, is_published: true, **attrs)
      report "created #{slug}"
    end

    def update_page(page, slug, attrs)
      page.assign_attributes(attrs)
      changed = page.changed?
      page.save! if changed
      report "#{changed ? 'updated' : 'unchanged'} #{slug}"
    end

    def edited_in_admin?(page, attrs)
      page.title != attrs[:title] || page.body != attrs[:body]
    end

    def force?
      ENV['FORCE'] == '1'
    end

    def report(line)
      $stdout.puts(line)
    end

    def read_content_file(path)
      File.read(path).strip
    rescue Errno::ENOENT
      raise ArgumentError, "Content file not found: #{path}"
    end

    def section_heading(key)
      I18n.t("transdimension.about.#{key}")
    end
  end
end
