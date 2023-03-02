require 'spec_helper'

describe Marketo::Rails::API::Pagination do
  describe Marketo::Rails::API::Pagination::TokenPaginator do
    subject { described_class.new(5) }

    context '#params' do
      it 'respects provided batch size' do
        expect(subject.params[:batchSize]).to eq(5)
      end

      it 'does not have a page token on the first page' do
        expect(subject.params[:nextPageToken]).to be_nil
      end
    end

    context '#next?' do
      it 'is true before loading the first page' do
        expect(subject.next?).to be_truthy
      end

      it 'is true if loaded page has a next page token' do
        subject.prev_page = { nextPageToken: 'token' }
        expect(subject.next?).to be_truthy
      end

      it 'is false after loading the last page' do
        subject.prev_page = { result: 'foo' }
        expect(subject.next?).to be_falsey
      end
    end

    context '#next' do
      it 'moves the page cursor' do
        subject.prev_page = { nextPageToken: 'token' }
        subject.next
        expect(subject.params[:nextPageToken]).to eq('token')
      end
    end
  end

  describe Marketo::Rails::API::Pagination::OffsetPaginator do
    subject { described_class.new(2) }

    context '#params' do
      it 'respects provided batch size' do
        expect(subject.params[:maxReturn]).to eq(2)
      end

      it 'starts at zero offset' do
        expect(subject.params[:offset]).to eq(0)
      end
    end

    context '#next?' do
      it 'is true before loading the first page' do
        expect(subject.next?).to be_truthy
      end

      it 'is true if previous page data size matches the batch size' do
        subject.prev_page = { result: [1, 2] }
        expect(subject.next?).to be_truthy
      end

      it 'is false if previous page data size is less than the batch size' do
        subject.prev_page = { result: [1] }
        expect(subject.next?).to be_falsey
      end
    end
  end
end
