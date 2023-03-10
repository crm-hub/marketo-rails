module Marketo
  module Rails
    module ETL
      class Registry
        class << self
          def sync_objects
            @sync_objects ||= []
          end

          def register(name)
            sync_objects << name
          end

          def find(name)
            sync_objects.find { |klass| klass.name == name }
          end
        end
      end
    end
  end
end
