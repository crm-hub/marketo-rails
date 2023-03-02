module Marketo
  module Rails
    module Callbacks
      def self.included(base)
        adapter = Adapters::Registry.new(base).adapter
        base.__send__ :include, adapter.const_get(:Callbacks)
      end
    end
  end
end
