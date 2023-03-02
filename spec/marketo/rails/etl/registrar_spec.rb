require 'spec_helper'

describe Marketo::Rails::ETL::Registrar do
  before(:all) do
    module DummySyncObject; end
  end

  after(:all) { remove_classes(DummySyncObject) }

  it 'registers the object in the registry when included' do
    DummySyncObject.__send__ :include, described_class
    expect(Marketo::Rails::ETL::Registry.sync_objects).to include(DummySyncObject)
  end
end
