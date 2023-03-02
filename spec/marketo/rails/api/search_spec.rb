require 'spec_helper'

describe Marketo::Rails::API::Search do
  before(:all) do
    class DummyClass
      PAGINATOR = Marketo::Rails::API::Pagination::OffsetPaginator

      def self.adapter
        Marketo::Rails::Adapters::Default
      end
    end

    class DummyClient
      def self.get(_path, params:)
        { result: (params[:offset]...[params[:maxReturn], 5].min).to_a }
      end
    end
  end

  after(:all) { remove_classes(DummyClass, DummyClient) }

  let(:batch_size) { 3 }
  let(:search_params) { { q: 1 } }
  subject { described_class.new(DummyClass, '/foo', batch_size, params: search_params) }

  it 'uses the paginator from klass config' do
    expect(subject.paginator).to be_a(DummyClass::PAGINATOR)
  end

  it 'uses the paginator to check if there is a next page' do
    expect(subject.paginator).to receive(:next?)
    subject.next?
  end

  context 'searching' do
    before do
      allow(DummyClass).to receive(:client).and_return(DummyClient)
    end

    context '#execute' do
      it 'loads data for the current page' do
        expected_params = { q: 1, offset: 0, maxReturn: batch_size }
        expect(DummyClient).to receive(:get).with('/foo', params: expected_params).and_call_original
        subject.execute
      end

      it 'returns search results' do
        expect(subject.execute).to be_a(Marketo::Rails::API::Search::Results)
      end

      it 'records results as a previous page for the paginator' do
        subject.execute
        expect(subject.paginator.prev_page).to eq({ result: [0, 1, 2] })
      end
    end

    context '#next' do
      it 'moves the cursor to the new page' do
        expect(subject.paginator).to receive(:next)
        subject.next
      end

      it 'loads the next page data' do
        expect(subject).to receive(:execute)
        subject.next
      end
    end

    context '#all' do
      it 'returns search results' do
        expect(subject.all).to be_a(Marketo::Rails::API::Search::Results)
      end

      it 'loads all the data' do
        expect(subject).to receive(:execute).twice.and_call_original
        subject.all
      end

      it 'resets current page offset' do
        subject.paginator.prev_page = 'foo'
        subject.all
        expect(subject.paginator.prev_page).to be_nil
      end
    end
  end

  describe Marketo::Rails::API::Search::Results do
    let(:results) { [{ id: 1 }] }
    subject { described_class.new(DummyClass, results) }

    it 'records search results' do
      expect(subject.results).to eq(results)
    end

    it 'allows to add results to the list' do
      subject.append([{ id: 2 }])
      expect(subject.results.size).to eq(2)
    end

    context '#records' do
      it 'includes the records mixin from klass adapter' do
        expect(subject).to respond_to(:records)
      end

      it 'searches for records matching result ids' do
        expect(DummyClass).to receive(:find).with([1])
        subject.records
      end
    end
  end
end
