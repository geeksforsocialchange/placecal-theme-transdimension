# frozen_string_literal: true

module Transdimension
  # Raised when the host PlaceCal is too old to serve this theme.
  class UnsupportedHost < StandardError; end

  class Engine < ::Rails::Engine
    # Not isolate_namespace: an extension plugs into the host app's routes,
    # helpers and layout rather than living behind a mount point.

    # Rails does not autoload app/views, and it autoloads app/components under
    # the top-level namespace, so the engine pushes its own directories with
    # explicit namespaces. Core does the same for Views and Components in
    # config/initializers/phlex.rb.
    initializer 'transdimension.phlex_namespaces', before: :set_autoload_paths do
      Rails.autoloaders.main.push_dir(
        root.join('app/views/transdimension'),
        namespace: Transdimension::Views
      )
      Rails.autoloaders.main.push_dir(
        root.join('app/components/transdimension'),
        namespace: Transdimension::Components
      )
    end

    # Every theme DSL setting this engine uses. The host has to provide all of
    # them; see "Minimum core" in the README.
    REQUIRED_THEME_SETTINGS = %i[
      stylesheet homepage_view head footer event_filter_style nav_cta nav_join map_style
    ].freeze

    # An older core has no extension registry, or a registry whose Theme is
    # missing settings added later. Either way the failure would otherwise be a
    # bare NoMethodError raised from inside an initializer, which says nothing
    # about what the installation needs. Name the missing capability instead.
    def self.verify_host!(registry = host_registry)
      return if registry.respond_to?(:register_theme)

      raise UnsupportedHost,
            'PlaceCal::Extensions.register_theme is not available: this theme needs a PlaceCal ' \
            'with the extension theme registry (see "Minimum core" in the engine README).'
    end

    def self.verify_theme!(theme)
      missing = REQUIRED_THEME_SETTINGS.reject { |setting| theme.respond_to?(setting) }
      return if missing.empty?

      raise UnsupportedHost,
            "PlaceCal::Theme does not support #{missing.join(', ')}: this theme needs a newer " \
            'PlaceCal (see "Minimum core" in the engine README).'
    end

    def self.host_registry
      defined?(::PlaceCal::Extensions) ? ::PlaceCal::Extensions : nil
    end

    # Theme registration (#3368 D1). Runs before core's config/initializers,
    # which is why core requires the registry from config/application.rb.
    initializer 'transdimension.register_theme' do
      Engine.verify_host!

      PlaceCal::Extensions.register_theme(:transdimension) do |theme|
        Engine.verify_theme!(theme)

        theme.stylesheet 'transdimension/theme'
        theme.homepage_view 'Transdimension::Views::Home'
        theme.head 'Transdimension::Components::Head'
        theme.footer 'Transdimension::Components::Footer'
        theme.event_filter_style :day_strip
        # PageHeader.elm: the Donate button (PHT Donorbox) at the end of the nav
        theme.nav_cta 'transdimension.header.donate', 'https://donorbox.org/the-trans-dimension'
        # PageHeader.elm has no Join link; PageFooter.elm carries it instead
        theme.nav_join false
        # Pink-tinted OpenFreeMap style shipped with the engine
        theme.map_style 'transdimension'
      end
    end
  end
end
