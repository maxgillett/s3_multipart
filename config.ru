require 'rubygems'
require 'bundler'

Bundler.require :development

Combustion.initialize! :active_record, :action_controller,
                       :action_view, :sprockets

S3Multipart.configure do |config|
  config.bucket_name   = 'bitcast-bucket'
  config.s3_access_key = 'AKIAJ356WICGRKWQ6LHA'
  config.s3_secret_key = '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'
end

run Combustion::Application

