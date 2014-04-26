# encoding: utf-8

$:.push File.expand_path("../lib", __FILE__)
require 's3_multipart/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = "s3_multipart"
  s.date        = Date.today
  s.version     = S3Multipart::VERSION
  s.authors     = ["Max Gillett"]
  s.email       = ["max.gillett@gmail.com"]
  s.homepage    = "https://github.com/maxgillett/s3_multipart"
  s.summary     = %q{Upload directly to S3 using multipart uploading}
  s.description = %q{See github for installation and configuration }
  s.extra_rdoc_files = ["README.md"]

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency "uuid",       ">= 2.3.6"
  s.add_dependency "xml-simple", ">= 1.1.2"

  s.add_development_dependency 'combustion', '~> 0.3.3'
  s.add_development_dependency "rails"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails', '~> 2.14', '>= 2.14.2'
  s.add_development_dependency 'capybara'
end
