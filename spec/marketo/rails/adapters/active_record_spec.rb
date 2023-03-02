require 'spec_helper'

describe Marketo::Rails::Adapters::ActiveRecord do
  before(:all) do
    class ARClass
      # Dummy model
    end
  end

  after(:all) { remove_classes(ARClass) }

  it 'is registered as an adapter' do
    expect(Marketo::Rails::Adapters::Registry.adapters[Marketo::Rails::Adapters::ActiveRecord]).not_to be_nil
    expect(Marketo::Rails::Adapters::Registry.adapters[Marketo::Rails::Adapters::ActiveRecord].call(ARClass)).to be_falsey
  end

  context '#records' do
    before(:all) do
      ARClass.include Marketo::Rails::Adapters::ActiveRecord::Records
    end

    let(:records) { ['foo', 'bar'] }

    it 'returns the list of records' do
      instance = ARClass.new
      allow(instance).to receive(:ids)
      allow(instance).to receive(:klass).and_return(double('class', primary_key: :id, where: records))
      expect(instance.records).to eq(['foo', 'bar'])
    end
  end

  context 'callbacks registration' do
    before do
      expect(ARClass).to receive(:after_commit).exactly(3).times
    end

    it 'registers model class for callbacks' do
      ARClass.include Marketo::Rails::Adapters::ActiveRecord::Callbacks
    end
  end
end
