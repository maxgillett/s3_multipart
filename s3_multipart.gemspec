# encoding: utf-8

require 's3_uploader/version'

Gem::Specification.new do |s|
  s.name        = "s3_multipart"
  s.version     = S3_Multipart::VERSION
  s.authors     = ["Max Gillett"]
  s.email       = ["max.gillett@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Upload directly to S3 using multipart uploading}
  s.description = %q{See github for installation and configuration }

  s.add_dependency "uuid"

  s.add_development_dependency "rails"
  s.add_development_dependency "sqlite3"

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end