module Marketo
  module Rails
    module ETL
      module Lead
        include Registrar

        DEFAULT_LOOKUP_FIELD = :email

        class InstanceMethods < BaseInstance
          def push
            lead = to_hash
            return if lead.empty?

            client.post(
              'rest/v1/leads.json',
              params: { action: 'createOrUpdate', input: [lead] }
            ).process_single_result![:id]
          end

          def pull(save: true)
            field_names = fields_to_pull.map { |field| field[:to] }
            if field_names.empty?
              return save ? false : {}
            end

            lead = client.get(
              "/test/v1/lead/#{marketo_id}.json",
              params: { fields: field_names }
            ).process_single_result!

            hashed_lead = from_marketo_hash(lead)
            return hashed_lead unless save

            target.assign_attributes(hashed_lead)
            target.save
          end

          def delete
            client.post(
              'rest/v1/leads/delete.json',
              params: { input: [{ id: marketo_id }] }
            ).process_single_result![:id]
          end

          private

          def marketo_id
            return target.send(id_field) unless id_field.nil?

            client.get(
              'rest/v1/leads.json',
              params: {
                filterType: DEFAULT_LOOKUP_FIELD,
                filterValues: target.send(DEFAULT_LOOKUP_FIELD),
                batchSize: 1,
                fields: 'id',
              }
            )[:result][:id]
          end
        end

        class ClassMethods < BaseClass
          MAX_BATCH_SIZE = 300
          PAGINATOR = API::Pagination::TokenPaginator

          def describe
            metadata = client.get('rest/v1/leads/describe2.json').json_body[:result].first
            searchable_fields = metadata[:searchableFields]
            metadata[:fields]
              .map { |field| field[:searchable] = searchable_fields.include?(field[:name]) }
              .transform_keys(&:underscore)
          end

          def search(filet_values, filter_by: DEFAULT_LOOKUP_FIELD, batch_size: MAX_BATCH_SIZE)
            field_names = fields_to_pull.map { |field| field[:to] }.join(',')
            filet_values = filet_values.join(',') if filet_values.is_a?(Array)
            API::Search.new(
              self,
              'rest/v1/leads.json',
              batch_size,
              params: {
                filterType: filter_by,
                filter_values: filet_values,
                fields: field_names,
              }
            )
          end
        end
      end
    end
  end
end
