# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "graylog2-resque/version"

Gem::Specification.new do |s|
  s.name        = "graylog2-resque"
  s.version     = Graylog2::Resque::VERSION
  s.authors     = ["Matt Conway"]
  s.email       = ["wr0ngway@yahoo.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "graylog2-resque"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_dependency "gelf"
  s.add_dependency "resque"
end
