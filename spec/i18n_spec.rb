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

    it 'has 95 keys total' do
      td_locale = en_locale['transdimension']
      flat_keys = flatten_keys(td_locale)
      expect(flat_keys.length).to eq(95)
    end
  end

  describe 'override keys' do # rubocop:disable Metrics/BlockLength
    let(:overrides_locale) do
      YAML.load_file(
        File.expand_path('../config/locales/overrides.en.yml', __dir__)
      )['en']
    end

    it 'contains only empty hash initially' do
      # WP 2.5 has no overrides yet; future work packages will add them
      expect(overrides_locale).to eq({})
    end

    it 'each override key exists in core' do
      core_locale = {}
      core_locale_files.each do |file|
        yaml = YAML.unsafe_load_file(file)
        deep_merge!(core_locale, yaml)
      end

      overrides_locale.each_key do |key|
        next if key == 'transdimension' # Engine namespace, not an override

        # Check that the key exists in core
        expect(check_key_exists?(core_locale, key)).to be_truthy,
                                                       "Override key '#{key}' does not exist in core i18n"
      end
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
    it 'resolves transdimension.home.title through the booted app' do
      expect(I18n.t('transdimension.home.title')).to eq('The Trans Dimension')
    end

    it 'resolves transdimension keys after core locale files are loaded' do
      # Verify that engine locale files are appended after core's
      expect(I18n.t('transdimension.site.title')).to eq('The Trans Dimension')
      expect(I18n.t('transdimension.site.strapline')).to eq('Space and spaces for us')
    end
  end
end
