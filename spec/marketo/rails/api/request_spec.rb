require 'spec_helper'

describe Marketo::Rails::API::Request do
  before do
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(Net::HTTPSuccess.new(1.0, '201', 'OK'))
  end

  context '#send' do
    it 'returns a Marketo::Rails::API::Response instance' do
      expect(described_class.send(host: 'www.example.com', path: '/foo')).to be_a(Marketo::Rails::API::Response)
    end

    it 'sends the request with provided host' do
      # 443 is the default port
      expect(Net::HTTP).to receive(:new).once.with('www.example.com', 443).and_call_original
      described_class.send(host: 'www.example.com', path: '/foo')
    end

    it 'sends the request with provided path' do
      expect(Net::HTTP::Get).to receive(:new).once.with('/foo', nil).and_call_original
      described_class.send(host: 'www.example.com', path: '/foo')
    end

    it 'sends GET request if method is not specified' do
      expect(Net::HTTP::Get).to receive(:new).once.and_call_original
      described_class.send(host: 'www.example.com', path: '/foo')
    end

    it 'sends POST request if method is Post' do
      expect(Net::HTTP::Post).to receive(:new).once.and_call_original
      described_class.send(host: 'www.example.com', path: '/foo', method: 'Post')
    end

    it 'sends headers with the request' do
      headers = { 'Authorization' => 'Bearer foo' }
      expect(Net::HTTP::Get).to receive(:new).with('/foo', headers).once.and_call_original
      described_class.send(host: 'www.example.com', path: '/foo', headers: headers)
    end
  end

  context '#request_uri' do
    it 'returns a URI object' do
      expect(described_class.request_uri(host: 'www.example.com', path: '/foo')).to be_a(URI)
    end

    it 'adds params to the uri query of the Get request' do
      uri = described_class.request_uri(host: 'www.example.com', path: '/foo', method: 'Get', params: { bar: 1})
      expect(uri.request_uri).to eq('/foo?bar=1')
    end
  end
end
