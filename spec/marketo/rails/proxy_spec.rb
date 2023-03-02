require 'spec_helper'

describe Marketo::Rails::Proxy do
  before(:all) do
    class ::IncludingModel
      include Marketo::Rails::Proxy
    end
  end

  after(:all) { remove_classes(IncludingModel) }

  it 'includes the adapter proxy' do
    expect(IncludingModel).to respond_to(:adapter)
  end

  context '#settings' do
    it 'returns an instance of the Settings class' do
      expect(IncludingModel.settings).to be_a(Marketo::Rails::Settings)
    end

    context 'with specific options' do
      before do
        IncludingModel.settings(id_field: 'email')
      end

      it 'applies the settings' do
        expect(IncludingModel.settings.options[:id_field]).to eq('email')
      end

      it 'updates the settings' do
        IncludingModel.settings(id_field: 'marketo_id')
        expect(IncludingModel.settings.options[:id_field]).to eq('marketo_id')
      end
    end

    context 'when called with a block' do
      before do
        IncludingModel.settings do
          maps :foo, :bar
        end
      end

      it 'sets the mappings' do
        mapping = IncludingModel.settings.mappings.first
        expect(mapping[:name]).to eq(:foo)
        expect(mapping[:to]).to eq(:bar)
      end
    end
  end

  context 'class proxy' do
    it 'sets up a proxy method on the class' do
      expect(IncludingModel).to respond_to(:__marketo__)
    end

    it 'uses object type from settings for the proxy class' do
      IncludingModel.settings(object_type: 'Lead')
      expect(IncludingModel.__marketo__).to be_a(Marketo::Rails::ETL::Lead::ClassMethods)
    end
  end

  context 'instance proxy' do
    it 'sets up a proxy method on instances' do
      expect(IncludingModel.new).to respond_to(:__marketo__)
    end

    it 'uses object type from settings for the proxy class' do
      IncludingModel.settings(object_type: 'Lead')
      expect(IncludingModel.new.__marketo__).to be_a(Marketo::Rails::ETL::Lead::InstanceMethods)
    end
  end
end
