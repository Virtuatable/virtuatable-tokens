# frozen_string_literal: true

module Controllers
  # This controller holds the action to transform an authorization code into
  # a usable access token that will be passed to the API.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Tokens < Core::Controllers::Base
    post '/' do
      api_created Core.svc.tokens.create_from_authorization(**sym_params)
    end

    post '/refresh' do
      api_created Core.svc.tokens.create_from_token(**sym_params)
    end
  end
end
