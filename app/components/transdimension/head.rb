# frozen_string_literal: true

# Markup the theme pushes into <head>: fonts and the web manifest link.
# Rendered by core's layout for any site on the transdimension theme
# (#3368 D1/D3). Empty until WP 2.2 adds the Typekit font loader.
class Transdimension::Components::Head < Components::Base
  def view_template
    comment { ' transdimension theme head ' }
  end
end
