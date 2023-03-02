module Marketo
  module Rails
    module API
      class Search
        attr_reader :klass, :path, :params, :paginator

        delegate :next?, to: :paginator

        def initialize(klass, path, batch_size, params: {})
          @klass = klass
          @path = path
          @paginator = klass.const_get(:PAGINATOR).new(batch_size)
          @params = params
        end

        def all
          paginator.prev_page = nil
          results = execute

          while next?
            next_page = self.next
            results.append(next_page.results)
          end

          paginator.prev_page = nil
          results
        end

        def execute
          response = klass.client.get(path, params: search_params)
          paginator.prev_page = response
          Results.new(klass, response[:result].to_a)
        end

        def next
          paginator.next
          execute
        end

        private

        def fetch
          klass.client.get(path, params: search_params)
        end

        def search_params
          params.merge(paginator.params)
        end

        class Results
          attr_reader :klass, :results

          def initialize(klass, results = [])
            @klass = klass
            @results = results
            metaclass = class << self; self; end
            metaclass.__send__ :include, klass.adapter.const_get(:Records)
          end

          def append(new_results)
            @results += new_results
          end

          def ids
            @results.map { |result| result[:id] }
          end
        end
      end
    end
  end
end
