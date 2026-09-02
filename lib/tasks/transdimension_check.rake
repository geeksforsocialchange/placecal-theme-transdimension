# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :transdimension do
  desc 'Verify the Trans Dimension Site record is configured correctly'
  task check: :environment do
    site_slug = ENV.fetch('TD_SITE_SLUG', 'transdimension')
    site = Site.find_by(slug: site_slug)

    failures = []
    warnings = []

    # Check: site exists and is published
    if site.nil?
      failures << "FAIL: Site with slug '#{site_slug}' not found"
    else
      if site.is_published
        puts 'PASS: Site exists and is published'
      else
        failures << 'FAIL: Site is not published'
      end

      # Check: URL present and starts with https://
      if site.url.present? && site.url.start_with?('https://')
        puts "PASS: URL is present and uses HTTPS (#{site.url})"
      else
        failures << 'FAIL: URL is missing or does not start with https://'
      end

      # Check: theme is transdimension
      if site.theme == 'transdimension'
        puts 'PASS: Theme is set to transdimension'
      else
        failures << "FAIL: Theme is '#{site.theme}', expected 'transdimension'"
      end

      # Check: Partnership tags include London and Manchester
      tag_names = site.tags.where(type: 'Partnership').pluck(:name, :id)
      london_tag = tag_names.find { |name, _id| name.casecmp('london').zero? }
      manchester_tag = tag_names.find { |name, _id| name.casecmp('manchester').zero? }

      if london_tag && manchester_tag
        _, london_id = london_tag
        _, manchester_id = manchester_tag
        puts "PASS: Partnership tags include London (id: #{london_id}) and Manchester (id: #{manchester_id})"
      else
        missing = []
        missing << 'London' unless london_tag
        missing << 'Manchester' unless manchester_tag
        failures << "FAIL: Missing partnership tags: #{missing.join(', ')}"
      end

      # Check: contact_email present and valid
      if site.contact_email.present?
        if site.contact_email.match?(URI::MailTo::EMAIL_REGEXP)
          puts "PASS: Contact email is present and valid (#{site.contact_email})"
        else
          failures << "FAIL: Contact email format is invalid (#{site.contact_email})"
        end
      else
        failures << 'FAIL: Contact email is not set'
      end

      # Check: site admin present
      if site.site_admin.present?
        puts "PASS: Site admin is set (#{site.site_admin.display_name})"
      else
        failures << 'FAIL: Site admin is not set'
      end

      # Check: logo present
      if site.logo.present? && site.logo.file.present?
        puts 'PASS: Logo is present'
      else
        failures << 'FAIL: Logo is not present'
      end

      # Check: hero image present
      if site.hero_image.present? && site.hero_image.file.present?
        puts 'PASS: Hero image is present'
      else
        failures << 'FAIL: Hero image is not present'
      end

      # Check: neighbourhoods empty (warn if any are present)
      if site.neighbourhoods.any?
        neighbourhood_names = site.neighbourhoods.pluck(:name).join(', ')
        warnings << "WARN: Site has neighbourhoods (expected none): #{neighbourhood_names}"
      else
        puts 'PASS: No neighbourhoods configured (as expected)'
      end

      # Check: pages exist and are published
      about_page = site.pages.find_by(slug: 'about')
      privacy_page = site.pages.find_by(slug: 'privacy')

      if about_page&.is_published
        puts 'PASS: About page exists and is published'
      else
        warnings << "WARN: About page is missing or not published (run transdimension:seed_pages[#{site_slug}])"
      end

      if privacy_page&.is_published
        puts 'PASS: Privacy page exists and is published'
      else
        warnings << "WARN: Privacy page is missing or not published (run transdimension:seed_pages[#{site_slug}])"
      end
    end

    # Print warnings
    warnings.each { |warning| puts warning }

    # Print failures and exit with error code if any exist
    if failures.any?
      failures.each { |failure| puts failure }
      exit(1)
    end
  end
end
# rubocop:enable Metrics/BlockLength
