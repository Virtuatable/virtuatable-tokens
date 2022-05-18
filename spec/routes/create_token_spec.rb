# frozen_string_literal: true

RSpec.describe 'POST /tokens' do
  def app
    Controllers::Tokens.new
  end

  let!(:account) { create(:account) }
  let!(:application) { create(:application, creator: account) }
  let!(:authorization) do
    create(:authorization, application: application, account: account)
  end

  describe 'Nominal case' do
    before do
      post '/', {
        authorization_code: authorization.code,
        client_id: application.client_id,
        client_secret: application.client_secret
      }
    end

    it 'Returns a 201 (Created) status code' do
      expect(last_response.status).to be 201
    end

    it 'Returns the correct body' do
      expectation = Core::Models::OAuth::AccessToken.first.value
      expect(last_response.body).to include_json({ token: expectation })
    end

    describe 'token attributes' do
      let!(:token) { Core::Models::OAuth::AccessToken.first }

      it 'Has the value returned by the creation request' do
        expect(token.value).to eq JSON.parse(last_response.body)['token']
      end
      it 'Has a nil generator has it has not been issued during a refresh' do
        expect(token.generator).to be nil
      end
      it 'Has an authorization' do
        expect(token.authorization.id.to_s).to eq authorization.id.to_s
      end
      it 'Has marked the authorization as used' do
        expect(authorization.reload.used?).to be true
      end
    end
  end

  describe 'Error cases' do
    describe 'When the authorization code is not given' do
      before do
        post '/', {
          client_id: application.client_id,
          client_secret: application.client_secret
        }
      end

      it 'Returns a 400 (Bad Request) status code' do
        expect(last_response.status).to be 400
      end

      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          field: 'authorization_code', error: 'required'
        )
      end
    end

    describe 'When the authorization code is not found' do
      before do
        post '/', {
          client_id: application.client_id,
          client_secret: application.client_secret,
          authorization_code: 'unknown'
        }
      end

      it 'Returns a 404 (Not Found) status code' do
        expect(last_response.status).to be 404
      end

      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          field: 'authorization_code', error: 'unknown'
        )
      end
    end

    describe 'When the client ID is not given' do
      before do
        post '/', {
          authorization_code: authorization.code,
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
        post '/', {
          client_id: 'unknown',
          authorization_code: authorization.code,
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
        post '/', {
          authorization_code: authorization.code,
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
        post '/', {
          client_id: application.client_id,
          authorization_code: authorization.code,
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

    describe 'when the authorization code belongs to another app' do
      let!(:second_app) do
        create(:application, name: 'Another brilliant app', creator: account)
      end

      before do
        post '/', {
          client_id: second_app.client_id,
          authorization_code: authorization.code,
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

    describe 'when the authorization code has already been used' do
      let!(:previous_token) { create(:token, authorization: authorization) }

      before do
        post '/', {
          authorization_code: authorization.code,
          client_id: application.client_id,
          client_secret: application.client_secret
        }
      end

      it 'Returns a 403 (Forbidden) status code' do
        expect(last_response.status).to be 403
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          field: 'authorization_code', error: 'used'
        )
      end
    end
  end
end
