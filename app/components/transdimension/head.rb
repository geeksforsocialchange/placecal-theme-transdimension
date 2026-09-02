# frozen_string_literal: true

# Markup the theme pushes into <head>. Rendered by core's layout for any site on
# the transdimension theme (#3368 D1/D3).
#
# Covik Sans comes from Adobe Typekit (D16: the licence is held), kit qwi3qrw.
# The tags follow the Elm site's elm-pages.config.mjs headTagsTemplate: the two
# preconnects, the preload and the stylesheet, all pointing at the same kit.
#
# One deviation. Elm loads the stylesheet with media="print" and an onload
# handler that swaps it to "all", with a <noscript> copy as the fallback, so the
# font never blocks the first paint. Phlex rejects event-handler attributes
# (Phlex::ArgumentError, "Unsafe attribute name detected: onload"), so the
# stylesheet is linked plainly instead. Same font, one render-blocking request,
# and no inline JavaScript.
class Transdimension::Components::Head < Components::Base
  TYPEKIT_CSS = 'https://use.typekit.net/qwi3qrw.css'

  def view_template
    link(rel: 'preconnect', href: 'https://use.typekit.net', crossorigin: true)
    link(rel: 'preconnect', href: 'https://p.typekit.net', crossorigin: true)
    link(rel: 'preload', as: 'style', href: TYPEKIT_CSS)
    link(rel: 'stylesheet', href: TYPEKIT_CSS)
  end
end
