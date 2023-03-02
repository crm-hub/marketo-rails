require 'net/http'
require 'uri'

module Marketo
  module Rails
    module API
      module Request
        module ClassMethods
          def send(host:, path:, method: 'Get', params: {}, headers: nil)
            uri = request_uri(host: host, path: path, method: method, params: params)
            http = Net::HTTP.new(uri.host, uri.port)
            http.read_timeout = 10
            http.open_timeout = 5
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE

            request = Object.const_get("Net::HTTP::#{method}").new(uri.request_uri, headers)
            request.body = params.to_json if method == 'Post' && params.any?
            request['Content-Type'] = 'application/json'

            Response.new(http.request(request))
          end

          def request_uri(host:, path:, method: 'Get', params: {})
            return URI::HTTPS.build(host: host, path: path) if method == 'Post' || params.empty?

            URI::HTTPS.build(host: host, path: path, query: params.to_query)
          end
        end

        extend ClassMethods
      end
    end
  end
end
