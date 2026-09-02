# frozen_string_literal: true

# The Trans Dimension homepage. Skeleton only (WP 2.1): later work packages
# fill in the hero, day strip and content sections.
class Transdimension::Views::Home < Views::Base
  prop :site, Site, reader: :private

  def view_template
    h1 { t('transdimension.home.title') }
  end
end
