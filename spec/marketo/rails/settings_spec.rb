require 'spec_helper'

describe Marketo::Rails::Settings do
  context 'without options' do
    it 'sets sync object to Lead' do
      expect(described_class.new.sync_object).to eq(Marketo::Rails::ETL::Lead)
    end
  end

  context 'with valid options' do
    let(:settings) { described_class.new(object_type: 'Lead', id_field: :marketo_id) }

    it 'creates correct setting definition' do
      expect(settings.sync_object).to eq(Marketo::Rails::ETL::Lead)
      expect(settings.options[:id_field]).to eq(:marketo_id)
    end

    it 'updates options' do
      settings.update_options(id_field: :id)
      expect(settings.options[:id_field]).to eq(:id)
    end
  end

  context 'with invalid options' do
    it 'raises an error for invalid object_type' do
      expect { described_class.new(object_type: 'Foo') }.to raise_error(ArgumentError)
    end
  end

  context '#maps' do
    let(:settings) { described_class.new }

    it 'creates correct mapping definition' do
      settings.maps(:name, :first_name, direction: :push)
      expect(settings.mappings.first).to eq({ name: :name, to: :first_name, direction: :push })
    end

    it 'syncs both ways by default' do
      settings.maps(:name, :first_name)
      expect(settings.mappings.first[:direction]).to eq(:bidirectional)
    end

    it 'raises an error for invalid sync direction' do
      expect { settings.maps(:name, :first_name, direction: :foo) }.to raise_error(ArgumentError)
    end

    context 'pull processor' do
      it 'accepts a method name' do
        settings.maps(:name, :first_name, pull_processor: :foo)
        expect(settings.mappings.first[:pull_processor]).to eq(:foo)
      end

      it 'accepts a proc' do
        pull_processor = -> { 'foo' }
        settings.maps(:name, :first_name, pull_processor: pull_processor)
        expect(settings.mappings.first[:pull_processor]).to eq(pull_processor)
      end

      it 'raises an error for invalid processor' do
        expect { settings.maps(:name, :first_name, pull_processor: []) }.to raise_error(ArgumentError)
      end
    end

    context 'push processor' do
      it 'accepts a method name' do
        settings.maps(:name, :first_name, push_processor: :foo)
        expect(settings.mappings.first[:push_processor]).to eq(:foo)
      end

      it 'accepts a proc' do
        push_processor = -> { 'foo' }
        settings.maps(:name, :first_name, push_processor: push_processor)
        expect(settings.mappings.first[:push_processor]).to eq(push_processor)
      end

      it 'raises an error for invalid processor' do
        expect { settings.maps(:name, :first_name, push_processor: []) }.to raise_error(ArgumentError)
      end
    end
  end
end
