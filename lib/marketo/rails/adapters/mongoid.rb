module Marketo
  module Rails
    module Adapters
      module Mongoid
        Registry.register(
          self,
          ->(klass) { defined?(::Mongoid::Document) && klass.respond_to?(:ancestors) && klass.ancestors.include?(::Mongoid::Document) }
        )

        module Records
          def records
            klass.where(:id.in => ids)
          end
        end

        module Callbacks
          def self.included(base)
            base.after_create  { |document| document.__marketo__.push }
            base.after_update  { |document| document.__marketo__.push }
            base.after_destroy { |document| document.__marketo__.delete }
          end
        end
      end
    end
  end
end
