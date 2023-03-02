require 'spec_helper'

describe Marketo::Rails::Callbacks do
  before(:all) do
    class ::DefaultModel
      include Marketo::Rails::Callbacks
    end

    class ::ArModel < ActiveRecord::Base
      include Marketo::Rails::Callbacks
    end
  end

  after(:all) { remove_classes(DefaultModel, ArModel) }

  context 'matching adapter exists' do
    it 'includes callbacks mixin from matching adapter' do
      expect(ArModel.ancestors).to include(Marketo::Rails::Adapters::ActiveRecord::Callbacks)
    end
  end

  context 'no matching adapter' do
    it 'includes callbacks mixin from default adapter' do
      expect(DefaultModel.ancestors).to include(Marketo::Rails::Adapters::Default::Callbacks)
    end
  end
end
