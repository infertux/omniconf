# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omniconf/version"

Gem::Specification.new do |s|
  s.name        = "omniconf"
  s.version     = Omniconf::VERSION
  s.authors     = ["Cédric Felizard"]
  s.email       = ["cedric@picklive.com"]
  s.homepage    = "https://github.com/Picklive/omniconf"
  s.summary     = %q{Merge multiple configuration sources into one.}
  s.description = %q{Merge configurations from multiple backends for easy use in a Rails application.}

  s.rubyforge_project = "omniconf"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "recursive-open-struct"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "activerecord"
end
