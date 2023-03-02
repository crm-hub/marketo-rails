require 'spec_helper'

describe Marketo::Rails::ETL::Base do
  before(:all) do
    class DummyModel
      attr_accessor :field1, :field2, :field3

      def self.settings
        return @settings if defined? @settings

        @settings = Marketo::Rails::Settings.new(id_field: :dummy_id)
        @settings.maps(:field1, :marketo_field1)
        @settings.maps(:field2, :marketo_field2, direction: :pull, pull_processor: ->(value) { value.upcase })
        @settings.maps(:field3, :marketo_field3, direction: :push, push_processor: -> { field3.upcase })
        @settings
      end
    end
  end

  after(:all) { remove_classes(DummyModel) }

  context 'when included' do
    before(:context) do
      class DummyImplementation
        include Marketo::Rails::ETL::Base

        delegate :settings, to: DummyModel
      end
    end

    after(:context) { remove_classes(DummyImplementation) }

    subject { DummyImplementation.new(DummyModel) }

    it 'provides means to get pull fields' do
      expect(subject.fields_to_pull.map { |field| field[:name] }).to eq([:field1, :field2])
    end

    it 'provides means to get push fields' do
      expect(subject.fields_to_push.map { |field| field[:name] }).to eq([:field1, :field3])
    end

    it 'allows to get id field from target class settings' do
      expect(subject.id_field).to eq(:dummy_id)
    end
  end

  describe Marketo::Rails::ETL::BaseClass do
    it 'includes base mixin' do
      expect(described_class.ancestors).to include(Marketo::Rails::ETL::Base)
    end

    context 'when extended' do
      before(:context) do
        class DummyImplementation < Marketo::Rails::ETL::BaseClass; end
      end

      after(:context) { remove_classes(DummyImplementation) }

      subject { DummyImplementation.new(DummyModel) }

      it 'delegates #client to target class' do
        expect(DummyModel).to receive(:client)
        subject.client
      end

      it 'delegates #settings to target class' do
        expect(DummyModel).to receive(:settings)
        subject.settings
      end

      it 'delegates #adapter to target class' do
        expect(DummyModel).to receive(:adapter)
        subject.adapter
      end
    end
  end

  describe Marketo::Rails::ETL::BaseInstance  do
    it 'includes base mixin' do
      expect(described_class.ancestors).to include(Marketo::Rails::ETL::Base)
    end

    context 'when extended' do
      before(:context) do
        class DummyImplementation < Marketo::Rails::ETL::BaseInstance; end
      end

      after(:context) { remove_classes(DummyImplementation) }

      let(:model_instance) { DummyModel.new }
      subject { DummyImplementation.new(model_instance) }

      it 'delegates #client to target class' do
        expect(DummyModel).to receive(:client)
        subject.client
      end

      it 'delegates #settings to target class' do
        expect(DummyModel).to receive(:settings)
        subject.settings
      end

      it 'delegates #adapter to target class' do
        expect(DummyModel).to receive(:adapter)
        subject.adapter
      end

      context '#to_marketo_hash' do
        before do
          model_instance.field1 = 'foo'
          model_instance.field3 = 'bar'
        end

        it 'uses specified field names to construct the hash' do
          expect(subject.to_marketo_hash[:marketo_field1]).to eq('foo')
        end

        it 'executes specified push processors to construct the hash' do
          expect(subject.to_marketo_hash[:marketo_field3]).to eq('BAR')
        end
      end

      context '#from_marketo_hash' do
        let(:marketo_hash) { { marketo_field1: 'foo', marketo_field2: 'bar' } }

        it 'uses specified field names to construct the hash' do
          expect(subject.from_marketo_hash(marketo_hash)[:field1]).to eq('foo')
        end

        it 'executes specified pull processors to construct the hash' do
          expect(subject.from_marketo_hash(marketo_hash)[:field2]).to eq('BAR')
        end
      end
    end
  end
end
