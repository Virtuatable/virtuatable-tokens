# frozen_string_literal: true

source 'https://rubygems.org/'

group :development, :production, :test do
  gem 'dotenv'
  gem 'require_all'
  gem 'virtuatable-core', '1.6.0.dev0', require: 'core'
end

group :development, :production do
  gem 'puma'
end

group :development, :test do
  gem 'pry'
end

group :test do
  gem 'database_cleaner-mongoid'
  gem 'factory_bot'
  gem 'faker'
  gem 'rack-test', require: 'rack/test'
  gem 'rspec'
  gem 'rspec-json_expectations'
  gem 'rubocop'
end
