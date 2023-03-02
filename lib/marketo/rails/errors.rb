module Marketo
  module Rails
    module Errors
      class ExecutionError < StandardError; end

      class APIAuthenticationError < ExecutionError
      end

      class TemporaryAPIError < ExecutionError
      end

      # Record level errors (e.g. invalid value provided, object not found, etc.)
      class BadAPIRequest < ExecutionError
      end

      # Generic Marketo account or Marketo server related issues
      class RuntimeAPIError < ExecutionError
      end
    end
  end
end
