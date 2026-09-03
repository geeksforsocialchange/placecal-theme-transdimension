# frozen_string_literal: true

require 'rails_helper'

# The engine is only loadable by a PlaceCal that ships the extension theme DSL
# (#3368). Against an older core the registration used to fail with a bare
# NoMethodError from inside an initializer; it now names what is missing.
RSpec.describe 'host contract' do
  # A stand-in for an older PlaceCal::Theme: everything this engine uses except
  # nav_join, which was added with the footer Join link.
  let(:theme_without_nav_join) do
    settings = Transdimension::Engine::REQUIRED_THEME_SETTINGS - [:nav_join]
    Class.new do
      settings.each { |setting| define_method(setting) { |*| nil } }
    end.new
  end

  describe '.verify_host!' do
    it 'accepts the registry core provides' do
      expect { Transdimension::Engine.verify_host! }.not_to raise_error
    end

    it 'names the missing registry when the host has no extension support' do
      expect { Transdimension::Engine.verify_host!(nil) }
        .to raise_error(Transdimension::UnsupportedHost, /register_theme is not available/)
    end
  end

  describe '.verify_theme!' do
    it 'accepts the theme core provides' do
      theme = PlaceCal::Extensions.fetch_theme('transdimension')

      expect { Transdimension::Engine.verify_theme!(theme) }.not_to raise_error
    end

    it 'names the missing setting when the host theme is too old' do
      expect { Transdimension::Engine.verify_theme!(theme_without_nav_join) }
        .to raise_error(Transdimension::UnsupportedHost, /does not support nav_join/)
    end
  end
end
