require 'marketo/rails'
require 'active_record'

RSpec.configure do |config|
  config.formatter = 'documentation'
  config.color = true

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  config.before(:suite) do
    # TODO: Add marketo client connection
    # Elasticsearch::Model.client = Elasticsearch::Client.new(
    #   host: ELASTICSEARCH_URL,
    #   tracer: (ENV['QUIET'] ? nil : tracer)
    # )

    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:') unless ActiveRecord::Base.connected?
    require 'example_app/app'
  end

  config.after(:all) do
    ActiveRecord::Base.descendants.each do |model|
      next unless model.table_exists?

      ActiveRecord::Schema.define do
        drop_table model
      end
    end
  end
end

def remove_classes(*classes)
  classes.each do |klass|
    Object.send(:remove_const, klass.name.to_sym) if defined?(klass)
  end
end
