require 'spec_helper'

describe Marketo::Rails::Adapters::Default do
  before(:all) do
    class DefaultClass
      include Marketo::Rails::Adapters::Default::Records
    end
  end

  after(:all) { remove_classes(DefaultClass) }

  it 'has the default Records implementation' do
    instance = DefaultClass.new
    allow(instance).to receive(:ids)
    allow(instance).to receive(:klass).and_return(double('class', find: ['foo']))
    expect(instance.records).to eq(['foo'])
  end

  it 'hast the default Callback implementation' do
    expect(Marketo::Rails::Adapters::Default::Callbacks).to be_a(Module)
  end
end
