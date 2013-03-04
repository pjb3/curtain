# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Barry"]
  gem.email         = ["mail@paulbarry.com"]
  gem.description   = %q{A template rendering framework}
  gem.summary       = %q{A template rendering framework}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "curtain"
  gem.require_paths = ["lib"]
  gem.version       = "0.1.1"

  gem.add_runtime_dependency "activesupport"
  gem.add_runtime_dependency "tilt"

  gem.add_development_dependency "erubis"
  gem.add_development_dependency "haml"
  gem.add_development_dependency "slim"
end
