module Marketo
  module Rails
    module Adapters
      module ActiveRecord
        Registry.register(
          self,
          ->(klass) { defined?(::ActiveRecord::Base) && klass.respond_to?(:ancestors) && klass.ancestors.include?(::ActiveRecord::Base) }
        )

        module Records
          def records
            klass.where(klass.primary_key => ids)
          end
        end

        module Callbacks
          def self.included(base)
            base.class_eval do
              after_commit -> { __marketo__.push }, on: :create
              after_commit -> { __marketo__.push }, on: :update
              after_commit -> { __marketo__.delete }, on: :destroy
            end
          end
        end
      end
    end
  end
end
