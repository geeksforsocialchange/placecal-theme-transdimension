# frozen_string_literal: true

require_relative 'lib/transdimension/version'

Gem::Specification.new do |spec|
  spec.name        = 'placecal-theme-transdimension'
  spec.version     = Transdimension::VERSION
  spec.authors     = ['Geeks for Social Change']
  spec.email       = ['support@placecal.org']
  spec.homepage    = 'https://github.com/geeksforsocialchange/placecal-theme-transdimension'
  spec.summary     = 'The Trans Dimension theme for PlaceCal'
  spec.description = 'A PlaceCal extension engine providing the Trans Dimension theme: views, components, copy and prebuilt CSS. Contains no models, migrations or business logic. The AGPL covers the code only: the design assets packaged with it (illustrations, logos, favicons, the share image and the brand copy) are copyright Gendered Intelligence and may not be reused outside a PlaceCal-served Trans Dimension site without their permission. See the NOTICE file.'
  spec.license     = 'AGPL-3.0-only'

  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.required_ruby_version = '>= 3.2'

  # `**/*` matches directories too, and `gem build` warns on every one of them.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,content,lib}/**/*', 'LICENSE', 'NOTICE', 'README.md'].select { |f| File.file?(f) }
  end

  # Core is the host application, never a dependency of the theme.
  spec.add_dependency 'rails', '>= 8.0'
end
