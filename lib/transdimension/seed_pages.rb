# frozen_string_literal: true

module Transdimension
  # Seeds Trans Dimension static content into PlaceCal Pages.
  class SeedPages
    # Section headings; overridable via locale keys.
    DEFAULT_SECTION_HEADINGS = {
      accessibility: 'Our Accessibility Process', makers: 'Meet the Makers', placecal: 'Built using PlaceCal',
      gi: 'Gendered Intelligence', gfsc: 'Geeks for Social Change'
    }.freeze

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
        title: 'About',
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
      {
        accessibility: section_heading(:accessibility),
        makers: section_heading(:makers),
        gi: section_heading(:gi),
        gfsc: section_heading(:gfsc),
        placecal: section_heading(:placecal)
      }
    end

    def seed_privacy_page
      engine_root = Transdimension::Engine.root
      privacy_content = read_content_file(engine_root.join('content/privacy.md'))

      upsert_page(
        slug: 'privacy',
        title: 'Privacy Policy',
        body: "#{I18n.t('transdimension.privacy.subtitle')}\n\n#{privacy_content}",
        position: 20,
        show_in_nav: false
      )
    end

    def upsert_page(slug:, title:, body:, position:, show_in_nav:)
      page = site.pages.find_or_initialize_by(slug:)
      page.assign_attributes(
        title:,
        body:,
        position:,
        show_in_nav:,
        is_published: true
      )

      status = save_and_determine_status(page)
      Rails.logger.debug { "#{title} page: #{status}" }
    end

    def save_and_determine_status(page)
      if page.new_record?
        page.save!
        'created'
      elsif page.changed?
        page.save!
        'updated'
      else
        'unchanged'
      end
    end

    def read_content_file(path)
      File.read(path).strip
    rescue Errno::ENOENT
      raise ArgumentError, "Content file not found: #{path}"
    end

    def section_heading(key)
      I18n.t("transdimension.about.#{key}", default: DEFAULT_SECTION_HEADINGS[key])
    end
  end
end
