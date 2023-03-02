module Marketo
  module Rails
    module Adapters
      class Registry
        attr_reader :klass

        def initialize(klass)
          @klass = klass
        end

        def self.adapters
          @adapters ||= {}
        end

        def self.register(name, matcher)
          adapters[name] = matcher
        end

        def adapter
          adapters = self.class.adapters
          @adapter ||= adapters.keys.find { |name| adapters[name].call(klass) } || Marketo::Rails::Adapters::Default
        end
      end
    end
  end
end
