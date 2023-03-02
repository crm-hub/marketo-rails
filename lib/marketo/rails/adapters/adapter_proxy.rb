module Marketo
  module Rails
    module Adapters
      module AdapterProxy
        def self.included(base)
          base.class_eval do
            def self.adapter
              @adapter ||= Registry.new(self)
            end
          end
        end
      end
    end
  end
end
