# frozen_string_literal: true

# Boots the PlaceCal core application with this engine loaded, the way Bundler
# would load the gem in a real installation. Everything this used to spell out
# is core's knowledge and now lives in core's spec/extension_helper.rb; see
# "Engine specs" in core's doc/extensions.md, and README "Development" for the
# invocation. system_specs: true is for spec/system/accessibility_spec.rb.
require 'spec_helper'

PLACECAL_CORE = Pathname(ENV.fetch('PLACECAL_CORE_PATH', File.expand_path('../../PlaceCal', __dir__))).expand_path
require PLACECAL_CORE.join('spec/extension_helper').to_s
PlaceCal::ExtensionSpec.boot!(engine: 'transdimension', system_specs: true)
