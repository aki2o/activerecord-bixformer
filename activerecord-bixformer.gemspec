# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord-bixformer/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-bixformer"
  spec.version       = ActiveRecord::Bixformer::VERSION
  spec.authors       = ["Hiroaki Otsu"]
  spec.email         = ["ootsuhiroaki@gmail.com"]

  spec.summary       = %q{a framework for xross transformer between ActiveRecord and other format.}
  spec.description   = %q{a framework for xross transformer between ActiveRecord and other format.}
  spec.homepage      = "https://github.com/aki2o/activerecord-bixformer"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("activerecord", ">= 2.3.0")

  spec.add_development_dependency('sqlite3', '~> 1.3')
  spec.add_development_dependency('i18n', '~> 0.7.0')
  spec.add_development_dependency('enumerize', '~> 2.0.0')
  spec.add_development_dependency('booletania', '~> 0.0.2')

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "database_rewinder", "~> 0.6.4"
  spec.add_development_dependency "stackprof", "~> 0.2.9"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-doc"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-stack_explorer"
end
