# frozen_string_literal: true

# The Privacy Policy page (#3368 WP 3.12). Registered at the `privacy` slug,
# the one core route a theme page may replace.
#
# One markdown file under a standfirst, which is not a heading, so the page
# prepends it and lets core render the declared block.
class Transdimension::Views::Privacy < Views::ThemeContentPage
  content_root Transdimension::Engine.root.join('content')
  slug         'privacy'
  title        'transdimension.privacy.title'

  markdown 'privacy.md'

  private

  def page_body
    p { t('transdimension.privacy.subtitle') }
    super
  end
end
