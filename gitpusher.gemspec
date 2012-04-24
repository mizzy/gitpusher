# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gitpusher/version"

Gem::Specification.new do |s|
  s.name        = "gitpusher"
  s.version     = GitPusher::VERSION
  s.authors     = ["Gosuke Miyashita"]
  s.email       = ["gosukenator@gmail.com"]
  s.homepage    = "https://github.com/mizzy/gitpusher"
  s.summary     = %q{A command line tool for replicating git repositories from one service to another.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # dependencies
  s.add_dependency 'grit'
  s.add_dependency 'octokit'
  s.add_dependency 'pit'
end
