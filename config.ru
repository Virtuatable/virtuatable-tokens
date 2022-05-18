# frozen_string_literal: true

require 'core'

Mongoid.load!('config/mongoid.yml', ENV['RACK_ENV'].to_sym || :development)

require './controllers/tokens'

run Controllers::Tokens