module Marketo
  module Rails
    module Adapters
      module Default
        module Records
          def records
            klass.find(ids)
          end
        end

        module Callbacks
          # noop
        end
      end
    end
  end
end
