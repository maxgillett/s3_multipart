# encoding: utf-8

$:.push File.expand_path("../lib", __FILE__)
require 's3_multipart/version'

Gem::Specification.new do |s|
  s.name        = "s3_multipart"
  s.version     = S3Multipart::VERSION
  s.authors     = ["Max Gillett"]
  s.email       = ["max.gillett@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Upload directly to S3 using multipart uploading}
  s.description = %q{See github for installation and configuration }

  s.add_dependency "uuid"
  s.add_dependency "xml-simple"

  s.add_development_dependency 'combustion', '~> 0.3.3'
  s.add_development_dependency "rails"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end