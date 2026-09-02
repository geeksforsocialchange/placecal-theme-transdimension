# frozen_string_literal: true

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
require_relative 'transdimension/seed_pages'
