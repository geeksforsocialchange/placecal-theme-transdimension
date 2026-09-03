# frozen_string_literal: true

# The Privacy Policy page (#3368 WP 3.12). Registered at the `privacy` slug,
# the one core route a theme page may replace.
class Transdimension::Views::Privacy < Transdimension::Views::ContentPage
  private

  def slug
    'privacy'
  end

  def page_title
    t('transdimension.privacy.title')
  end

  def page_body
    p { t('transdimension.privacy.subtitle') }
    markdown('privacy.md')
  end
end
