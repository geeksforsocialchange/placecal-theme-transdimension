# frozen_string_literal: true

require 'rails_helper'

# What this engine says to a PlaceCal::Theme (#3368). The guards themselves are
# core's (PlaceCal::Extension, exercised by core's own fixture-engine specs);
# what is this repo's is the settings the theme block fills in.
#
# `respond_to?` alone cannot see the drift that is actually likely between a
# tag-pinned core and this engine: a setting whose signature changed. `icons`
# gaining a validated key, `og_image` dropping `width:` or `page` gaining a
# required kwarg all pass respond_to? and then raise ArgumentError from inside
# an initializer on the next boot.
#
# So register for real, against a throwaway PlaceCal::Theme built the way core
# builds one, and read the settings back. This is the check that fails loudly.
RSpec.describe 'host contract' do
  describe '.configure_theme' do
    let(:theme) { PlaceCal::Theme.new(:transdimension_contract_smoke) }

    before { Transdimension::Engine.configure_theme(theme) }

    it 'sets the views, nav and listing behaviour' do
      expect(theme.stylesheet).to eq('transdimension/theme')
      expect(theme.homepage_view).to eq('Transdimension::Views::Home')
      expect(theme.head).to eq('Transdimension::Components::Head')
      expect(theme.footer).to eq('Transdimension::Components::Footer')
      expect(theme.event_filter_style).to eq(:day_strip)
      expect(theme.map_style).to eq('transdimension')
      expect(theme.nav_join?).to be(false)
      expect(theme.menu_label?).to be(true)
      expect(theme.nav_cta)
        .to eq(label_key: 'transdimension.header.donate', url: Transdimension::Engine::DONATE_URL)
    end

    it 'sets the branding core reads into the head' do
      expect(theme.icons).to eq(Transdimension::Engine::ICONS)
      expect(theme.theme_color).to eq('#ff7aa7')
      expect(theme.background_color).to eq('#040f39')
      expect(theme.og_image)
        .to eq(path: 'transdimension/og-share.png', width: 1200, height: 630)
    end

    it 'registers the theme pages in nav order' do
      expect(theme.pages).to eq(
        'about' => { view: 'Transdimension::Views::About', nav_label_key: 'transdimension.nav.about' },
        'privacy' => { view: 'Transdimension::Views::Privacy', nav_label_key: nil }
      )
    end
  end
end
