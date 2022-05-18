# frozen_string_literal: true

FactoryBot.define do
  factory :empty_account, class: 'Core::Models::Account' do
    factory :account do
      username { Faker::Internet.username(specifier: (7..20)) }
      password { 'password' }
      password_confirmation { 'password' }
      email { Faker::Internet.email }
    end
  end
end
