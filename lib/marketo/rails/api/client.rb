module Marketo
  module Rails
    module API
      class Client
        attr_reader :host, :client_id, :client_secret, :access_token, :token_expires_at

        def initialize(host:, client_id:, client_secret:)
          @host = host
          @client_id = client_id
          @client_secret = client_secret
        end

        def get(path, params: {})
          send_wrapped_request(path, method: 'Get', params: params)
        end

        def post(path, params: {})
          send_wrapped_request(path, method: 'Post', params: params)
        end

        private

        def connected?
          token_expires_at && token_expires_at > Time.now
        end

        def connect
          response = Request.send(
            host: host,
            path: 'identity/oauth/token',
            params: {
              client_id: client_id,
              client_secret: client_secret,
              grant_type: 'client_credentials',
            }
          ).process!
          response_body = response.json_body

          @access_token = response_body[:access_token]
          @token_expires_at = Time.now + response_body[:expires_in].seconds
        end

        def send_wrapped_request(path, method:, params: {})
          wrap_request { Request.send(host: host, path: path, method: method, params: params, headers: auth_headers).process! }
        end

        def wrap_request
          # Check authentication before sending any request
          connect unless connected?
          yield
        rescue Marketo::Rails::Errors::APIAuthenticationError
          # Refresh access token and retry
          connect
          yield
        rescue Marketo::Rails::Errors::TemporaryAPIError
          # Wait for 3 seconds and retry
          sleep(3)
          yield
        end

        def auth_headers
          { 'Authorization' => "Bearer #{access_token}" }
        end
      end
    end
  end
end
