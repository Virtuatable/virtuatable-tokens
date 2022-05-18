# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'bundler'
Bundler.require ENV['RACK_ENV'].to_sym

Mongoid.load!('config/mongoid.yml', ENV['RACK_ENV'].to_sym)

require_rel 'support/**/*.rb'
require './controllers/tokens'
