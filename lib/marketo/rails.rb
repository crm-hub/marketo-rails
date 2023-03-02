require 'active_support/core_ext/module/delegation'

require 'marketo/rails/api/pagination'
require 'marketo/rails/api/search'
require 'marketo/rails/api/request'
require 'marketo/rails/api/response'
require 'marketo/rails/api/client'

require 'marketo/rails/adapters/registry'
require 'marketo/rails/adapters/default'
require 'marketo/rails/adapters/active_record'
require 'marketo/rails/adapters/mongoid'
require 'marketo/rails/adapters/adapter_proxy'

require 'marketo/rails/etl/registry'
require 'marketo/rails/etl/registrar'
require 'marketo/rails/etl/base'
require 'marketo/rails/etl/lead'

require 'marketo/rails/callbacks'
require 'marketo/rails/errors'
require 'marketo/rails/settings'
require 'marketo/rails/proxy'

module Marketo
  module Rails
    def self.included(base)
      base.class_eval do
        include Marketo::Rails::Proxy
      end
    end

    module ClassMethods
      def client
        @client
      end

      def client=(client)
        @client = client
      end
    end

    extend ClassMethods
  end
end
