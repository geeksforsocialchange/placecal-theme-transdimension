# frozen_string_literal: true

# The Trans Dimension footer, rendered by core's layout in place of
# Components::Footer for sites on this theme (theme footer slot, #3368 D1).
#
# Ported from src/Theme/PageFooter.elm. Three full-width bands:
#
#   1. pink   - the footer wordmark and the link list
#   2. dark   - "Follow us out there" and "Created by"
#   3. pink   - the charity/company details, the credits, the copyright line
#              and the "powered by PlaceCal" lockup
#
# Deviation from the Elm original: its middle band has a third column, the
# newsletter sign-up form, which the coordinator dropped, so the two remaining
# columns are centred instead. And TD had no log-in link at all; one is kept at
# the end of the legal band in small type so site admins can still reach admin.
class Transdimension::Components::Footer < Components::Base
  prop :site, ::Site
  prop :navigation, Array, default: -> { [] }

  SOCIAL_LINKS = [
    %w[insta footer_insta.svg],
    %w[twitter footer_twitter.svg],
    %w[facebook footer_facebook.svg]
  ].freeze

  CREDITS = [1, 2, 3].freeze

  def view_template
    footer(class: 'td-footer') do
      div(class: 'td-footer__top') do
        render_wordmark
        render_nav
      end
      div(class: 'td-footer__middle') do
        render_social
        render_created_by
      end
      div(class: 'td-footer__legal') do
        render_info
        render_credits
      end
    end
  end

  private

  def render_wordmark
    div(class: 'td-footer__wordmark') do
      image_tag('transdimension/TDD_Logo_Footer.svg', alt: t('transdimension.site.title'))
    end
  end

  def render_nav
    nav(class: 'td-footer__nav', role: 'navigation') do
      ul do
        nav_links.each do |label, path|
          li { link_to(label, path) }
        end
      end
    end
  end

  # PageFooter.elm lists Events, Partners, News, About, Privacy, Join us. The
  # first four come from the site's derived navigation (D6) minus Home, so a
  # site with no news or no About page simply lists fewer; Privacy is core's
  # own route and goes second to last, with Join us kept at the end.
  def nav_links
    links = @navigation.reject { |_label, path| path_root?(path) }
    join, rest = links.partition { |_label, path| path_join?(path) }
    rest + [[t('navigation.site.privacy'), privacy_path]] + join
  end

  def path_root?(path)
    path.to_s.split('?').first == root_path
  end

  def path_join?(path)
    path.to_s.split('?').first == get_in_touch_path
  end

  def render_social
    div(class: 'td-footer__social') do
      p(class: 'td-footer__subhead') { t('transdimension.footer.social') }
      ul(class: 'td-footer__social-list') do
        SOCIAL_LINKS.each do |name, file|
          li do
            a(href: t("transdimension.footer.#{name}_link"), target: '_blank', rel: 'noopener') do
              image_tag("transdimension/#{file}", alt: t("transdimension.footer.#{name}_alt"))
            end
          end
        end
      end
    end
  end

  def render_created_by
    div(class: 'td-footer__created-by') do
      p(class: 'td-footer__subhead') { t('transdimension.footer.byline') }
      ul(class: 'td-footer__logo-list') do
        li do
          a(href: t('transdimension.external.gfsc_home'), target: '_blank', rel: 'noopener') do
            image_tag('transdimension/footer_gfsc.svg', alt: t('transdimension.footer.gfsc_alt'))
          end
        end
        li do
          a(href: t('transdimension.external.gendered_intelligence_home'), target: '_blank', rel: 'noopener') do
            image_tag('transdimension/GI_pink.svg', alt: t('transdimension.external.gendered_intelligence_name'))
          end
        end
      end
    end
  end

  def render_info
    div(class: 'td-footer__block') do
      p(class: 'td-footer__info td-footer__info--title') { t('transdimension.footer.info_title') }
      %w[info_charity info_company info_office].each do |key|
        p(class: 'td-footer__info td-footer__info--tight') { t("transdimension.footer.#{key}") }
      end
    end
  end

  def render_credits
    div(class: 'td-footer__block') do
      p(class: 'td-footer__info td-footer__info--title') { t('transdimension.footer.credit_title') }
      p(class: 'td-footer__info') { render_credit_list }
      p(class: 'td-footer__info') { t('transdimension.footer.copyright', year: Time.zone.today.year) }
      render_powered_by
      render_log_in
    end
  end

  # "Illustrations by Harry Woodgate, design by Squid, website by GFSC."
  def render_credit_list
    CREDITS.each_with_index do |index, position|
      plain ', ' if position.positive?
      plain t("transdimension.footer.credit_#{index}_text")
      plain ' '
      a(href: t("transdimension.footer.credit_#{index}_link"), target: '_blank', rel: 'noopener') do
        t("transdimension.footer.credit_#{index}_name")
      end
    end
    plain '.'
  end

  def render_powered_by
    a(href: 'https://placecal.org', class: 'td-footer__powered-by') do
      image_tag('transdimension/footer_placecal.svg', alt: t('transdimension.footer.powered_by'))
    end
  end

  def render_log_in
    p(class: 'td-footer__login') { link_to(t('navigation.site.log_in'), new_user_session_path) }
  end
end
