# frozen_string_literal: true

# Boots the PlaceCal core application with this engine loaded, the way Bundler
# would load the gem in a real installation. See README "Development" for the
# invocation, and core's doc/extensions.md for the contract.
require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'

PLACECAL_CORE = Pathname.new(
  ENV.fetch('PLACECAL_CORE_PATH', File.expand_path('../../PlaceCal', __dir__))
).expand_path

raise "PlaceCal core not found at #{PLACECAL_CORE}; set PLACECAL_CORE_PATH" unless PLACECAL_CORE.join('config/application.rb').exist?

require PLACECAL_CORE.join('config/application').to_s
# Required before the environment initialises so the engine's initializers run
# and the theme is registered.
require_relative '../lib/transdimension'
require PLACECAL_CORE.join('config/environment').to_s

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'capybara/rspec'
require 'pundit/rspec'

# Core's spec support files (helpers, VCR, shared contexts) are reusable here.
PLACECAL_CORE.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f.to_s }

FactoryBot.definition_file_paths = [PLACECAL_CORE.join('spec/factories')]
FactoryBot.reload

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [PLACECAL_CORE.join('spec/fixtures')]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Core freezes time in its own suite; match it so shared factories behave.
  config.before { Timecop.freeze(Time.zone.local(2022, 11, 8)) }
  config.after { Timecop.return }
end
