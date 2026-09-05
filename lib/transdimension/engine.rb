# frozen_string_literal: true

module Transdimension
  class Engine < ::Rails::Engine
    # Not isolate_namespace: an extension plugs into the host app's routes,
    # helpers and layout rather than living behind a mount point.
    #
    # PlaceCal::Extension is core's shared engine infrastructure: it pushes the
    # Phlex namespaces for the app/views/transdimension and
    # app/components/transdimension directories this engine ships, runs the
    # host and theme guards, and registers the theme declared below. See core's
    # doc/extensions.md.
    include PlaceCal::Extension

    # Every theme DSL setting this engine uses. The host has to provide all of
    # them; see "Minimum core" in the README. Core pins this engine by tag in
    # its own Gemfile and the two ship together, so there is no host with some
    # of these and not the rest.
    required_settings %i[
      stylesheet homepage_view font_stylesheet footer event_filter_style nav_cta nav_join map_style
      menu_label icons theme_color background_color og_image page
    ]

    # PageHeader.elm: the Donate button at the end of the nav goes to the
    # Partnership's Donorbox page. A URL is not a UI string, so it is a constant
    # here rather than a locale key; only the button label is translated.
    DONATE_URL = 'https://donorbox.org/the-trans-dimension'

    # Covik Sans comes from Adobe Typekit (D16: the licence is held), kit
    # qwi3qrw. Core's font_stylesheet slot renders exactly the tags the Elm
    # site's elm-pages.config.mjs headTagsTemplate emitted: the two
    # preconnects, the preload and the stylesheet link.
    #
    # One deviation, and it predates this slot. Elm loads the stylesheet with
    # media="print" and an onload handler that swaps it to "all", with a
    # <noscript> copy as the fallback, so the font never blocks the first
    # paint. Same font, one render-blocking request, no inline JavaScript.
    TYPEKIT_CSS = 'https://use.typekit.net/qwi3qrw.css'
    TYPEKIT_PRECONNECT = %w[https://use.typekit.net https://p.typekit.net].freeze

    # Favicons, touch icon, Safari mask icon and share card, copied from the
    # live transdimension.uk (#3368 WP 3.10).
    ICONS = {
      favicon_32: 'transdimension/favicons/favicon-32x32.png',
      favicon_16: 'transdimension/favicons/favicon-16x16.png',
      apple_touch_icon: 'transdimension/favicons/apple-touch-icon.png',
      mask_icon: 'transdimension/favicons/safari-pinned-tab.svg',
      icon_192: 'transdimension/favicons/android-chrome-192x192.png',
      icon_512: 'transdimension/favicons/android-chrome-512x512.png',
      # site.webmanifest on the live site: the Safari pinned-tab mask colour.
      # Core takes it in the icons hash rather than as a setting of its own.
      mask_icon_color: '#FF7AA7'
    }.freeze

    theme :transdimension do |theme|
      register_layout(theme)
      register_branding(theme)
      register_pages(theme)
    end

    # The views, nav and listing behaviour core reads for a site on this theme.
    def self.register_layout(theme)
      theme.stylesheet 'transdimension/theme'
      theme.homepage_view 'Transdimension::Views::Home'
      theme.font_stylesheet TYPEKIT_CSS, preconnect: TYPEKIT_PRECONNECT
      theme.footer 'Transdimension::Components::Footer'
      theme.event_filter_style :day_strip
      # PageHeader.elm: the Donate button (PHT Donorbox) at the end of the nav
      theme.nav_cta 'transdimension.header.donate', DONATE_URL
      # PageHeader.elm has no Join link; PageFooter.elm carries it instead
      theme.nav_join false
      # Pink-tinted OpenFreeMap style shipped with the engine
      theme.map_style 'transdimension'
      # PageHeader.elm labels the mobile toggle "Menu" rather than drawing a
      # hamburger.
      theme.menu_label true
    end

    def self.register_branding(theme)
      theme.icons(**ICONS)
      # site.webmanifest on the live site: theme #ff7aa7, splash background the
      # dark blue the brand sits on.
      theme.theme_color '#ff7aa7'
      theme.background_color '#040f39'
      # Share card: the live site's logo artwork (556x320) centred on TD dark
      # blue at 1200x630, the size Facebook and Twitter want for a large card.
      # The live site links the bare 556x320 file while claiming 1200x675.
      theme.og_image 'transdimension/og-share.png', width: 1200, height: 630
    end

    # The theme's own static pages (#3368 WP 3.12). Content lives in this
    # engine's content/ directory and is rendered by the theme's own views, so
    # nothing has to be seeded into the host database. About carries a nav
    # label; Privacy does not, because PageFooter.elm puts the Privacy link in
    # the footer and the header has never shown it.
    def self.register_pages(theme)
      theme.page 'about', 'Transdimension::Views::About', nav_label_key: 'transdimension.nav.about'
      theme.page 'privacy', 'Transdimension::Views::Privacy'
    end
  end
end
