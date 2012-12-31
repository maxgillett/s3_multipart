require 'rubygems'
require 'bundler'

Bundler.require :development

require 'capybara/rspec'

Combustion.initialize! :active_record, :action_controller,
                       :action_view, :sprockets

require 'rspec/rails'
require 'capybara/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end