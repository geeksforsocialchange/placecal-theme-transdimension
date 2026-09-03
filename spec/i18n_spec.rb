# frozen_string_literal: true

require 'rails_helper'

describe 'Trans Dimension i18n' do # rubocop:disable Metrics/BlockLength
  let(:core_locale_path) do
    File.expand_path('../../PlaceCal/config/locales', __dir__)
  end

  let(:core_locale_files) do
    Dir.glob(File.join(core_locale_path, '*.yml')).sort
  end

  describe 'YAML validity' do
    it 'parses en.yml without errors' do
      expect do
        YAML.load_file(
          File.expand_path('../config/locales/en.yml', __dir__)
        )
      end.not_to raise_error
    end

    it 'parses overrides.en.yml without errors' do
      expect do
        YAML.load_file(
          File.expand_path('../config/locales/overrides.en.yml', __dir__)
        )
      end.not_to raise_error
    end
  end

  describe 'transdimension keys' do # rubocop:disable Metrics/BlockLength
    let(:en_locale) do
      YAML.load_file(
        File.expand_path('../config/locales/en.yml', __dir__)
      )['en']
    end

    def flatten_keys(hash, prefix = '')
      hash.each_with_object([]) do |(key, value), memo|
        full_key = "#{prefix}#{key}"
        if value.is_a?(Hash)
          memo.concat(flatten_keys(value, "#{full_key}."))
        else
          memo << full_key
        end
      end
    end

    it 'contains transdimension namespace' do
      expect(en_locale).to have_key('transdimension')
    end

    it 'contains no nil or blank values' do
      td_locale = en_locale['transdimension']
      flat_keys = flatten_keys(td_locale)
      flat_keys.each do |key_path|
        value = td_locale
        key_path.split('.').each { |part| value = value[part] }
        expect(value).to be_present, "Key transdimension.#{key_path} is blank"
      end
    end

    # The file holds only what the theme itself renders: copy that replaces a
    # core string lives in overrides.en.yml. Name the keys rather than counting
    # them, so a key deleted out from under a view fails here.
    it 'carries every key the footer component reads' do
      footer_keys = %w[
        social byline gfsc_alt info_title credit_title copyright powered_by
        insta_link twitter_link facebook_link insta_alt twitter_alt facebook_alt
        info_charity info_company info_office
        credit_1_text credit_1_name credit_1_link
        credit_2_text credit_2_name credit_2_link
        credit_3_text credit_3_name credit_3_link
      ]
      expect(en_locale['transdimension']['footer'].keys).to match_array(footer_keys)
    end

    it 'carries every key the homepage view and its cards read' do
      home_keys = %w[
        meta_title meta_description logo_alt intro_title intro_message
        intro_button events_header events_button events_empty event_by
        news_header news_button news_read_more
      ]
      expect(en_locale['transdimension']['home'].keys).to match_array(home_keys)
    end

    it 'carries the keys the page views and the theme registration read' do
      expect(en_locale['transdimension']['about'].keys)
        .to match_array(%w[title accessibility makers gi gfsc placecal])
      expect(en_locale['transdimension']['privacy'].keys).to match_array(%w[title subtitle])
      expect(en_locale['transdimension']['nav'].keys).to match_array(%w[about])
      expect(en_locale['transdimension']['site'].keys).to match_array(%w[title description])
      expect(en_locale['transdimension']['header'].keys).to match_array(%w[donate])
      expect(en_locale['transdimension']['external'].keys)
        .to match_array(%w[gfsc_home gendered_intelligence_home gendered_intelligence_name])
    end

    it 'holds no keys beyond those groups' do
      expect(en_locale['transdimension'].keys)
        .to match_array(%w[site external nav header footer home about privacy])
    end
  end

  describe 'override keys' do # rubocop:disable Metrics/BlockLength
    let(:overrides_locale) do
      YAML.load_file(
        File.expand_path('../config/locales/overrides.en.yml', __dir__)
      )['en']
    end

    it 'each override key exists in core' do
      core_locale = {}
      core_locale_files.each do |file|
        yaml = YAML.unsafe_load_file(file)
        deep_merge!(core_locale, yaml.fetch('en', yaml))
      end

      flat = lambda do |hash, prefix = ''|
        hash.flat_map { |k, v| v.is_a?(Hash) ? flat.call(v, "#{prefix}#{k}.") : ["#{prefix}#{k}"] }
      end
      flat.call(overrides_locale).each do |scoped_key|
        expect(scoped_key).to start_with('theme_overrides.transdimension.')
        key = scoped_key.delete_prefix('theme_overrides.transdimension.')

        expect(check_key_exists?(core_locale, key)).to be_truthy,
                                                       "Override key '#{key}' does not exist in core i18n"
      end
    end

    it 'applies the overrides only for sites on this theme' do
      helper = Class.new { include PlaceCal::ThemeTranslation }.new
      Current.site = build(:site, theme: 'transdimension')
      expect(helper.t('navigation.site.join')).to eq('Join us')
      expect(helper.t('region_filter.all')).to eq('Everywhere')
      Current.site = build(:site, theme: 'pink')
      expect(helper.t('region_filter.all')).to eq('All')
    ensure
      Current.reset
    end

    def deep_merge!(target, source)
      source.each do |key, value|
        if value.is_a?(Hash) && target[key].is_a?(Hash)
          deep_merge!(target[key], value)
        else
          target[key] = value
        end
      end
      target
    end

    def check_key_exists?(locale_hash, key_string)
      parts = key_string.split('.')
      current = locale_hash
      parts.each do |part|
        return false unless current.is_a?(Hash) && current.key?(part)

        current = current[part]
      end
      true
    end
  end

  describe 'i18n resolution' do
    it 'resolves transdimension.home.meta_title through the booted app' do
      expect(I18n.t('transdimension.home.meta_title')).to eq('Home')
    end

    it 'resolves transdimension keys after core locale files are loaded' do
      # Verify that engine locale files are appended after core's
      expect(I18n.t('transdimension.site.title')).to eq('The Trans Dimension')
      expect(I18n.t('transdimension.header.donate')).to eq('Donate')
    end
  end
end
