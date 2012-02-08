# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omniconf/version"

Gem::Specification.new do |s|
  s.name        = "omniconf"
  s.version     = Omniconf::VERSION
  s.authors     = ["Cedric Felizard"]
  s.email       = ["cedric@picklive.com"]
  s.homepage    = "https://github.com/Picklive/omniconf"
  s.summary     = %q{Merge multiple configuration sources into one.}
  s.description = %q{Merge configurations from multiple back-ends for easy use in a complex application.}

  s.rubyforge_project = "omniconf"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake', '~> 0.9'
  s.add_development_dependency 'rspec', '~> 2.8'
  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'activerecord', '~> 3.2'
end
