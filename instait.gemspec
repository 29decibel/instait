# -*- encoding: utf-8 -*-
require File.expand_path('../lib/instait/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["mike.d"]
  gem.email         = ["mike.d.1984@gmail.com"]
  gem.description   = %q{instagram filter like ruby gem}
  gem.summary       = %q{instagram filter like ruby gem}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "instait"
  gem.require_paths = ["lib"]
  gem.version       = Instait::VERSION
end
