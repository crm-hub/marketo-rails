module Marketo
  module Rails
    class Settings
      attr_reader :sync_object, :options, :mappings

      def initialize(options = {})
        @sync_object = Marketo::Rails::ETL::Registry.find("Marketo::Rails::ETL::#{options[:object_type] || 'Lead'}")
        raise ArgumentError, "'#{options[:object_type]}' is not a valid object_type" if @sync_object.nil?

        @options = parsed_options(options)
        @mappings = []
      end

      def maps(name, to, options = {})
        mapping = { name: name, to: to }
        direction = options[:direction] || :bidirectional
        raise ArgumentError, ':direction can be :push, :pull or :bidirectional' unless [:push, :pull, :bidirectional].include?(direction)

        mapping[:direction] = direction

        unless options[:pull_processor].nil?
          validate_processor!(options[:pull_processor])
          mapping[:pull_processor] = options[:pull_processor]
        end

        unless options[:push_processor].nil?
          validate_processor!(options[:push_processor])
          mapping[:push_processor] = options[:push_processor]
        end

        @mappings << mapping
      end

      def update_options(options)
        @options = parsed_options(options)
      end

      private

      def validate_processor!(processor)
        return if processor.is_a?(Proc) || processor.is_a?(Symbol)

        raise ArgumentError, 'Expecting method name or a Proc to be provided as a processor'
      end

      def parsed_options(options)
        opts = {}
        opts[:id_field] = options[:id_field]
        opts
      end
    end
  end
end
