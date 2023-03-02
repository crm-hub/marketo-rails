require 'spec_helper'

describe Marketo::Rails::Adapters::Registry do
  before(:all) do
    class DummyAdapter
      Marketo::Rails::Adapters::Registry.register(self, ->(klass) { klass == 'foo' })
    end
  end

  after(:all) { remove_classes(DummyAdapter) }

  it 'registers adapters' do
    expect(described_class.adapters).not_to be_empty
  end

  context '#adapter' do
    it 'returns the adapter class when matching adapter exists' do
      expect(Marketo::Rails::Adapters::Registry.new('foo').adapter).to eq(DummyAdapter)
    end

    it 'falls back to the default adapter if there is no matching adapter' do
      expect(Marketo::Rails::Adapters::Registry.new('bar').adapter).to eq(Marketo::Rails::Adapters::Default)
    end
  end
end
