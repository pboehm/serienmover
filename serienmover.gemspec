# -*- encoding: utf-8 -*-
require File.expand_path('../lib/serienmover/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Philipp Böhm"]
  gem.email         = ["philipp@i77i.de"]
  gem.description   = %q{Tool that moves your episodes into a specific directory structure}
  gem.summary       = %q{Tool that moves your episodes into a specific directory structure}
  gem.homepage      = "http://github.com/pboehm/serienmover"

  gem.add_dependency('serienrenamer', '~> 0.0.7')

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "serienmover"
  gem.require_paths = ["lib"]
  gem.version       = Serienmover::VERSION
end
