# frozen_string_literal: true

FactoryBot.define do
  factory :empty_authorization, class: 'Core::Models::OAuth::Authorization' do
    factory :authorization do
      code { SecureRandom.hex }
    end
  end
end
