lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marketo/rails/version'

Gem::Specification.new do |spec|
  spec.name          = 'marketo-rails'
  spec.version       = Marketo::Rails::VERSION
  spec.license       = 'MIT'
  spec.summary       = 'Easily sync Rails models instances with your Marketo objects'
  spec.description   = ''
  spec.authors       = ['Rafayel Sedrakyan']
  spec.email         = 'rafaelsedrakyan@gmail.com'
  spec.homepage      = 'https://github.com/crm-hub/marketo-rails'
  spec.metadata      = { 'source_code_uri' => 'https://github.com/crm-hub/marketo-rails', 'rubygems_mfa_required' => 'true' }
  spec.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency 'activesupport', '>= 6'
end
