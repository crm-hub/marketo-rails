require 'spec_helper'

describe Marketo::Rails::Adapters::AdapterProxy do
  before(:all) do
    class ::IncludingModel
      include Marketo::Rails::Adapters::AdapterProxy
    end
  end

  after(:all) { remove_classes(IncludingModel) }

  it 'sets up adapter method for the class' do
    expect(IncludingModel).to respond_to(:adapter)
  end

  it 'pulls an adapter from registry' do
    expect(Marketo::Rails::Adapters::Registry).to receive(:new).with(IncludingModel)
    IncludingModel.adapter
  end
end
