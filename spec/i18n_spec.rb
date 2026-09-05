# frozen_string_literal: true

require 'rails_helper'

describe 'Trans Dimension i18n' do
  # PLACECAL_CORE is resolved from PLACECAL_CORE_PATH in rails_helper. Hardcoding
  # ../../PlaceCal here made the override check silently vacuous for anyone whose
  # core checkout is not named exactly that: every key would fail as "does not
  # exist in core" against an empty hash.
  let(:core_locale_files) do
    PLACECAL_CORE.glob('config/locales/*.yml').sort_by(&:to_s).map(&:to_s)
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

  describe 'transdimension keys' do
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

    # The header of en.yml claims every key is read by app/ or lib/. Enforce it,
    # so a key orphaned by a future view edit fails here rather than sitting in
    # the file reading as live copy. Six of them are only ever reached through an
    # interpolated t() call, so each call site becomes a pattern, not a literal.
    it 'every key is read by app/ or lib/' do
      source = Pathname(__dir__).parent.glob('{app,lib}/**/*.rb').map(&:read).join("\n")
      patterns = source.scan(/transdimension\.[a-z0-9_.]*(?:\#\{[^}]*\}[a-z0-9_.]*)*/).uniq.map do |ref|
        literals = ref.split(/\#\{[^}]*\}/, -1).map { |part| Regexp.escape(part) }
        /\A#{literals.join('[a-z0-9_]+')}\z/
      end

      flatten_keys(en_locale['transdimension']).each do |key|
        full_key = "transdimension.#{key}"
        expect(patterns).to be_any { |pattern| pattern.match?(full_key) },
                            "Key #{full_key} is in en.yml but nothing in app/ or lib/ reads it"
      end
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
      Current.theme = PlaceCal::Theme.for(build(:site, theme: 'transdimension'))
      expect(helper.t('navigation.site.join')).to eq('Join us')
      expect(helper.t('region_filter.all')).to eq('Everywhere')
      Current.theme = PlaceCal::Theme.for(build(:site, theme: 'pink'))
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
