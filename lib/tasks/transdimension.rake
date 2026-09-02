# frozen_string_literal: true

namespace :transdimension do
  desc 'Seed About and Privacy pages into PlaceCal from Trans Dimension content'
  task :seed_pages, [:site_slug] => :environment do |_t, args|
    site_slug = args[:site_slug]
    raise ArgumentError, 'Usage: rake transdimension:seed_pages[site_slug]' if site_slug.blank?

    Transdimension::SeedPages.new(site_slug).call
  end
end
