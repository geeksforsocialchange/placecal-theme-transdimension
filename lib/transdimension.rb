# frozen_string_literal: true

# One line, first, so an installation whose core predates the shared engine
# infrastructure fails by name. It has to come before the module body below:
# `extend Phlex::Kit` would otherwise raise a bare NameError first on a host
# that has not loaded Phlex.
abort('placecal-theme-transdimension needs a PlaceCal with PlaceCal::Extension; see "Minimum core" in README.md.') unless defined?(PlaceCal::Extension)

# The Trans Dimension: a PlaceCal extension (Rails engine) that registers the
# `transdimension` theme. Extensions hold views, components, assets and copy
# only: no models, no migrations, no business logic. See core's
# doc/extensions.md and #3368.
module Transdimension
  # Phlex namespaces. Core owns Views and Components; an extension owns
  # <Extension>::Views and <Extension>::Components.
  module Views; end

  module Components
    extend Phlex::Kit
  end
end

require_relative 'transdimension/version'
require_relative 'transdimension/engine'
