require 'rubygems'
require 'bundler'

Bundler.require :development

#  require 'rspec/rails'
#  require 'capybara/rails'
#  require 'capybara/rspec'
require 'sauce/capybara'
require 'sauce/parallel'

Combustion.initialize! 

# Engine config initializer
require 'setup_credentials.rb'

RSpec.configure do |config|
  #config.use_transactional_fixtures = true
end



Capybara.default_driver = :sauce
Capybara.server_port = 9000

BROWSERS = [
  #["Windows", "Firefox", "18"],
  #["Linux", "Chrome", nil],
  #["Mac", "Firefox", "19"],
   ["Mac", "Firefox", "17"]
]

index = ENV["TEST_ENV_NUMBER"] != "" ? (ENV["TEST_ENV_NUMBER"].to_i - 1) : 0
platform = BROWSERS[index]
Sauce.config do |config|
  #start_tunnel_for_parallel_tests(config)
  config[:os] = platform[0]
  config[:browser] = platform[1]
  config[:version] = platform[2]
end
