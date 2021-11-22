
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'partitional/version'

Gem::Specification.new do |spec|
  spec.name          = 'partitional'
  spec.version       = Partitional::VERSION
  spec.authors       = ['Sho Kusano']
  spec.email         = ['rosylilly@aduca.org']

  spec.summary       = 'Provides partial model to your Rails'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/rosylilly/partitional'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'

  spec.add_dependency 'activemodel'
  spec.add_dependency 'activesupport'
end
