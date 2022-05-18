# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :deletion
    DatabaseCleaner[:mongoid].clean
  end
  config.after do
    DatabaseCleaner[:mongoid].clean
  end
end
