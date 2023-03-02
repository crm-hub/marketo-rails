require 'spec_helper'

describe Marketo::Rails do
  context '#client=' do
    before do
      Marketo::Rails.client = 'Foo'
    end

    it 'allows the client to be set' do
      expect(Marketo::Rails.client).to eq('Foo')
    end
  end

  context 'mixin' do
    before(:all) do
      class IncludingModel
        include Marketo::Rails
      end
    end

    after(:all) { remove_classes(IncludingModel) }

    it 'includes the proxy' do
      expect(IncludingModel).to respond_to(:__marketo__)
      expect(IncludingModel.new).to respond_to(:__marketo__)
    end
  end
end
