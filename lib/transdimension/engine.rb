# frozen_string_literal: true

module Transdimension
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

    # Theme registration (#3368 D1). Runs before core's config/initializers,
    # which is why core requires the registry from config/application.rb.
    initializer 'transdimension.register_theme' do
      PlaceCal::Extensions.register_theme(:transdimension) do |theme|
        theme.stylesheet 'transdimension/theme'
        theme.homepage_view 'Transdimension::Views::Home'
        theme.head 'Transdimension::Components::Head'
        theme.footer 'Transdimension::Components::Footer'
        theme.event_filter_style :day_strip
      end
    end
  end
end
