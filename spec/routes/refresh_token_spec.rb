# frozen_string_literal: true

RSpec.describe 'POST /tokens/refresh' do
  def app
    Controllers::Tokens.new
  end

  let!(:account) { create(:account) }
  let!(:application) { create(:application, creator: account) }
  let!(:authorization) do
    create(:authorization, application: application, account: account)
  end
  let!(:token) { create(:token, authorization: authorization) }

  describe 'Nominal case' do
    before do
      post '/refresh', {
        token: token.value,
        client_id: application.client_id,
        client_secret: application.client_secret
      }
    end

    it 'Returns a 201 (Created) status code' do
      expect(last_response.status).to be 201
    end

    it 'Returns the correct body' do
      expectation = Core::Models::OAuth::AccessToken.last.value
      expect(last_response.body).to include_json({ token: expectation })
    end

    describe 'token attributes' do
      let!(:created) { Core::Models::OAuth::AccessToken.last }

      it 'Has the value returned by the creation request' do
        expect(created.value).to eq JSON.parse(last_response.body)['token']
      end
      it 'has a generator with the value of the previous token' do
        expect(created.generator.id.to_s).to eq token.id.to_s
      end
      it 'Has an authorization set at creation' do
        expect(created.authorization.id.to_s).to eq authorization.id.to_s
      end
    end
  end

  describe 'Error cases' do
    describe 'When the token value is not given' do
      before do
        post '/refresh', {
          client_id: application.client_id,
          client_secret: application.client_secret
        }
      end

      it 'Returns a 400 (Bad Request) status code' do
        expect(last_response.status).to be 400
      end

      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          field: 'token', error: 'required'
        )
      end
    end

    describe 'When the token is not found' do
      before do
        post '/refresh', {
          client_id: application.client_id,
          client_secret: application.client_secret,
          token: 'unknown'
        }
      end

      it 'Returns a 404 (Not Found) status code' do
        expect(last_response.status).to be 404
      end

      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          field: 'token', error: 'unknown'
        )
      end
    end

    describe 'When the client ID is not given' do
      before do
        post '/refresh', {
          token: token.value,
          client_secret: application.client_secret
        }
      end

      it 'Returns a 400 (Bad Request) status code' do
        expect(last_response.status).to be 400
      end

      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          field: 'client_id', error: 'required'
        )
      end
    end

    describe 'When the client ID is not found' do
      before do
        post '/refresh', {
          client_id: 'unknown',
          token: token.value,
          client_secret: application.client_secret
        }
      end

      it 'Returns a 400 (Bad Request) status code' do
        expect(last_response.status).to be 404
      end

      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          field: 'client_id', error: 'unknown'
        )
      end
    end

    describe 'When the client secret is not given' do
      before do
        post '/refresh', {
          token: token.value,
          client_id: application.client_id
        }
      end

      it 'Returns a 400 (Bad Request) status code' do
        expect(last_response.status).to be 400
      end

      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          field: 'client_secret', error: 'required'
        )
      end
    end

    describe 'When the client secret is not the correct one' do
      before do
        post '/refresh', {
          client_id: application.client_id,
          token: token.value,
          client_secret: 'wrong_secret'
        }
      end

      it 'Returns a 403 (Forbidden) status code' do
        expect(last_response.status).to be 403
      end

      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          field: 'client_secret', error: 'wrong'
        )
      end
    end

    describe 'when the token belongs to another app' do
      let!(:second_app) do
        create(:application, name: 'Another brilliant app', creator: account)
      end

      before do
        post '/refresh', {
          client_id: second_app.client_id,
          token: token.value,
          client_secret: second_app.client_secret
        }
      end

      it 'Returns a 400 (Bad Request) status code' do
        expect(last_response.status).to be 400
      end

      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          field: 'client_id', error: 'mismatch'
        )
      end
    end

    describe 'when the token has already been used' do
      let!(:other_token) { create(:token, generator: token, authorization: authorization) }

      before do
        post '/refresh', {
          token: token.value,
          client_id: application.client_id,
          client_secret: application.client_secret
        }
      end

      it 'Returns a 403 (Forbidden) status code' do
        expect(last_response.status).to be 403
      end

      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          field: 'token', error: 'used'
        )
      end
    end
  end
end
