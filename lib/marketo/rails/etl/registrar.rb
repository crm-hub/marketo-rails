module Marketo
  module Rails
    module ETL
      module Registrar
        def self.included(base)
          Registry.register(base)
        end
      end
    end
  end
end
