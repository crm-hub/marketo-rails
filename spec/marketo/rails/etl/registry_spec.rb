require 'spec_helper'

describe Marketo::Rails::ETL::Registry do
  before(:all) do
    module DummyRegisteredObject; end

    described_class.register(DummyRegisteredObject)
  end

  after(:all) { remove_classes(DummyRegisteredObject) }

  it 'registers sync objects' do
    expect(described_class.sync_objects).to include(DummyRegisteredObject)
  end

  it 'allows to find sync objects by name' do
    expect(described_class.find('DummyRegisteredObject')).to be(DummyRegisteredObject)
  end
end
