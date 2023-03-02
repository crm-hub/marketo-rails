module Marketo
  module Rails
    module API
      module Pagination
        class TokenPaginator
          attr_accessor :prev_page

          def initialize(batch_size)
            @batch_size = batch_size
            @next_page_token = nil
            @prev_page = nil
          end

          def params
            pagination_params = { batchSize: @batch_size }
            pagination_params[:nextPageToken] = @next_page_token unless @next_page_token.nil?
            pagination_params
          end

          def next?
            prev_page.nil? || !prev_page[:nextPageToken].nil?
          end

          def next
            @next_page_token = prev_page[:nextPageToken]
          end
        end

        class OffsetPaginator
          attr_accessor :prev_page

          def initialize(batch_size)
            @batch_size = batch_size
            @offset = 0
          end

          def params
            {
              offset: @offset,
              maxReturn: @batch_size,
            }
          end

          def next
            @offset += @batch_size
          end

          def next?
            prev_page.nil? || prev_page[:result].to_a.length == @batch_size
          end
        end
      end
    end
  end
end
