FactoryBot.define do
  factory :empty_token, class: Core::Models::OAuth::AccessToken do
    factory :token do
      value { SecureRandom.hex }
    end
  end
end