module Marketo
  module Rails
    module ETL
      module Base
        attr_reader :target

        def initialize(target)
          @target = target
        end

        def fields_to_pull
          settings.mappings.reject { |mapping| mapping[:direction] == :push }
        end

        def fields_to_push
          settings.mappings.reject { |mapping| mapping[:direction] == :pull }
        end

        def id_field
          settings.options[:id_field]
        end
      end

      class BaseClass
        include Base

        delegate :client, :settings, :adapter, to: :target
      end

      class BaseInstance
        include Base

        delegate :client, :settings, :adapter, to: :klass

        def klass
          target.class
        end

        def to_marketo_hash
          fields_to_push.each_with_object({}) do |field_mapping, obj_hash|
            obj_hash[field_mapping[:to]] = if field_mapping[:push_processor].nil?
                                             target.send(field_mapping[:name])
                                           else
                                             target.instance_exec(&field_mapping[:push_processor])
                                           end
          end
        end

        def from_marketo_hash(marketo_hash)
          fields_to_pull.each_with_object({}) do |field_mapping, obj_hash|
            marketo_value = marketo_hash[field_mapping[:to]]
            obj_hash[field_mapping[:name]] = if field_mapping[:pull_processor].nil?
                                               marketo_value
                                             else
                                               target.instance_exec(marketo_value, &field_mapping[:pull_processor])
                                             end
          end
        end
      end
    end
  end
end
