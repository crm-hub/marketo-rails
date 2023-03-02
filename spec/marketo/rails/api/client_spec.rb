require 'spec_helper'

describe Marketo::Rails::API::Client do
  let(:host) { 'example.marketo.com' }
  let(:client_id) { 'foo' }
  let(:client_secret) { 'bar' }
  let(:client) { described_class.new(host: host, client_id: client_id, client_secret: client_secret) }
  let(:response) do
    response = Marketo::Rails::API::Response.new(Net::HTTPSuccess.new(1.0, '201', 'OK'))
    allow(Marketo::Rails::API::Request).to receive(:send).and_return(response)
    response
  end

  context 'connection' do
    let(:auth_params) do
      {
        client_id: client_id,
        client_secret: client_secret,
        grant_type: 'client_credentials',
      }
    end
    let(:auth_response) do
      {
        access_token: 'token',
        expires_in: 50,
      }
    end

    before do
      allow(response).to receive(:process!).and_return(double('response', json_body: auth_response))
    end

    it 'fetches access credentials on the first request' do
      expect(Marketo::Rails::API::Request).to receive(:send).with(host: host, path: 'identity/oauth/token', params: auth_params).once
      client.get('/resource_path')
    end

    it 'stores access credentials for future requests' do
      client.get('/resource_path')
      expect(client.access_token).to eq(auth_response[:access_token])
      expect(client.token_expires_at).to be_within(1.second).of(Time.now + auth_response[:expires_in].seconds)
    end

    it 'reconnects if token is expired' do
      client.instance_variable_set(:@access_token, 'token')
      client.instance_variable_set(:@token_expires_at, Time.now - 5.seconds)
      expect(Marketo::Rails::API::Request).to receive(:send).with(host: host, path: 'identity/oauth/token', params: auth_params).once
      client.get('/resource_path')
    end

    it 'uses existing token for future requests' do
      client.instance_variable_set(:@access_token, 'token')
      client.instance_variable_set(:@token_expires_at, Time.now + 1.minute)
      expect(Marketo::Rails::API::Request).not_to receive(:send).with(host: host, path: 'identity/oauth/token', params: auth_params)
      client.get('/resource_path')
    end
  end

  context 'API requests' do
    let(:params) { { param1: 1 } }
    let(:headers) { { 'Authorization' => 'Bearer token' } }
    let(:successful_response) { double('response', json_body: {}) }

    before do
      client.instance_variable_set(:@access_token, 'token')
      client.instance_variable_set(:@token_expires_at, Time.now + 1.hour)
    end

    context '#get' do
      it 'sends a get request with Bearer authentication' do
        allow(response).to receive(:process!).and_return(successful_response)
        expect(Marketo::Rails::API::Request)
          .to receive(:send)
                .with(
                  host: host,
                  path: '/resource_path',
                  method: 'Get',
                  params: params,
                  headers: headers
                ).once
        client.get('/resource_path', params: params)
      end
    end

    context '#post' do
      it 'sends a post request with Bearer authentication' do
        allow(response).to receive(:process!).and_return(successful_response)
        expect(Marketo::Rails::API::Request)
          .to receive(:send)
                .with(
                  host: host,
                  path: '/resource_path',
                  method: 'Post',
                  params: params,
                  headers: headers
                ).once
        client.post('/resource_path', params: params)
      end
    end

    context 'wrapped request' do
      it 'reconnects and retries the request in case of a authentication failure' do
        call_count = 0
        allow(response).to receive(:process!) do
          call_count += 1
          call_count.odd? ? raise(Marketo::Rails::Errors::APIAuthenticationError) : successful_response
        end
        expect(Marketo::Rails::API::Request).to receive(:send).twice
        expect(client).to receive(:connect).once
        client.get('/resource_path', params: params)
      end

      it 'retries the request once in case of a temporary failure' do
        call_count = 0
        allow(response).to receive(:process!) do
          call_count += 1
          call_count.odd? ? raise(Marketo::Rails::Errors::TemporaryAPIError) : successful_response
        end
        expect(Marketo::Rails::API::Request).to receive(:send).twice
        client.get('/resource_path', params: params)
      end
    end
  end
end
