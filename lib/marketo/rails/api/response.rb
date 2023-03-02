module Marketo
  module Rails
    module API
      class Response
        AUTHENTICATION_ERROR_CODES = {
          ACCESS_TOKEN_INVALID: '601',
          ACCESS_TOKEN_EXPIRED: '602',
        }.freeze

        # if the execution encounters one of these, wait and retry the request
        TEMPORARY_ERROR_CODES = {
          BAD_GATEWAY: '502',
          REQUEST_TIMED_OUT: '604',
          TEMPORARY_UNAVAILABLE: '608',
          CONCURRENT_ACCESS_LIMIT_EXCEEDED: '615',
          RESOURCE_TEMPORARILY_UNAVAILABLE: '713',
        }.freeze

        attr_reader :http_response, :json_body

        def initialize(http_response)
          @http_response = http_response
        end

        def process!
          response_json = JSON.parse(http_response.body, { symbolize_names: true })
          errors = response_json[:errors] || []

          # Marketo returns 200 status code for failed requests except for authorization
          if http_response.is_a?(Net::HTTPSuccess) && errors.empty?
            @json_body = response_json
            return self
          end

          if http_response.is_a?(Net::HTTPUnauthorized) || AUTHENTICATION_ERROR_CODES.values.include?(errors.first[:code])

            raise Marketo::Rails::Errors::APIAuthenticationError, 'Provided credentials are invalid.'
          end

          if TEMPORARY_ERROR_CODES.values.include?(errors.first[:code])
            raise Marketo::Rails::Errors::TemporaryAPIError, "#{errors.first[:message]} (#{errors.first[:code]})"
          end

          raise(
            Marketo::Rails::Errors::RuntimeAPIError,
            errors.map { |error| "#{error[:message]} (#{error[:code]})" }.join("\n")
          )
        end

        def process_single_result!
          process! if json_body.nil?
          output = json_body[:result].first
          if output[:status] == 'skipped'
            error_message = output[:reasons].map { |error| "#{error[:message]} (#{error[:code]})" }
                                            .join("\n")

            raise Marketo::Rails::Errors::BadAPIRequest, error_message
          end

          output
        end
      end
    end
  end
end
