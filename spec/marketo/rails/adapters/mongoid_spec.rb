require 'spec_helper'

describe Marketo::Rails::Adapters::Mongoid do
  before(:all) do
    class MongoClass
      # Dummy model
    end
    ::Symbol.class_eval do
      def in
        self
      end
    end
  end

  after(:all) { remove_classes(MongoClass) }

  it 'is registered as an adapter' do
    expect(Marketo::Rails::Adapters::Registry.adapters[Marketo::Rails::Adapters::Mongoid]).not_to be_nil
    expect(Marketo::Rails::Adapters::Registry.adapters[Marketo::Rails::Adapters::Mongoid].call(MongoClass)).to be_falsey
  end

  context '#records' do
    before(:all) do
      MongoClass.include Marketo::Rails::Adapters::Mongoid::Records
    end

    let(:records) { ['foo', 'bar'] }

    it 'returns the list of records' do
      instance = MongoClass.new
      allow(instance).to receive(:ids).and_return([1, 2])
      allow(instance).to receive(:klass).and_return(double('class', where: records))
      expect(instance.records).to eq(records)
    end
  end

  context 'callbacks registration' do
    before do
      expect(MongoClass).to receive(:after_create).once
      expect(MongoClass).to receive(:after_update).once
      expect(MongoClass).to receive(:after_destroy).once
    end

    it 'registers model class for callbacks' do
      MongoClass.include Marketo::Rails::Adapters::Mongoid::Callbacks
    end
  end
end
