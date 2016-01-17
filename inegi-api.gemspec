$:.push File.expand_path("../lib", __FILE__)
require "inegi/api/version"

Gem::Specification.new do |s|
  s.name = "inegi-api"
  s.version = Inegi::API::VERSION
  s.authors = "Mario Alberto Chávez Cárdenas"
  s.email = ["mario.chavez@gmail.com"]
  s.license = "MIT"
  s.summary = %q{Ruby client for the INEGI API}
  s.description = %q{Ruby client for the INEGI API}

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_runtime_dependency "httparty", "~> 0.13.0"
  s.add_runtime_dependency "json", "~> 1.8.0"

  s.add_development_dependency "minitest"
  s.add_development_dependency "rake"
end
