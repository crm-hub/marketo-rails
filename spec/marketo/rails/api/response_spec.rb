require 'spec_helper'

describe Marketo::Rails::API::Response do
  context '#process!' do
    context 'response is a success' do
      subject do
        response = Net::HTTPSuccess.new(1.0, '200', 'OK')
        allow(response).to receive(:body).and_return({ result: 'foo' }.to_json)
        described_class.new(response).process!
      end

      it 'returns json body' do
        expect(subject.json_body).to be_a(Hash)
      end

      it 'symbolizes response keys' do
        expect(subject.json_body.keys).to include(a_kind_of(Symbol))
      end
    end

    context 'response is a failure' do
      let(:error_body) { { errors: [] } }

      context 'authentication error' do
        it 'raises APIAuthenticationError for unauthorized response' do
          response = Net::HTTPUnauthorized.new(1.0, '401', 'Unauthorized')
          allow(response).to receive(:body).and_return(error_body.to_json)
          expect { described_class.new(response).process! }.to raise_error(Marketo::Rails::Errors::APIAuthenticationError)
        end

        it 'raises APIAuthenticationError when wrong token provided' do
          response = Net::HTTPSuccess.new(1.0, '200', 'OK')
          error_body[:errors] << { code: described_class::AUTHENTICATION_ERROR_CODES[:ACCESS_TOKEN_INVALID] }
          allow(response).to receive(:body).and_return(error_body.to_json)
          expect { described_class.new(response).process! }.to raise_error(Marketo::Rails::Errors::APIAuthenticationError)
        end
      end

      it 'raises TemporaryAPIError when Marketo server responds with a temporary error code' do
        response = Net::HTTPSuccess.new(1.0, '200', 'OK')
        error_body[:errors] << { code: described_class::TEMPORARY_ERROR_CODES[:REQUEST_TIMED_OUT] }
        allow(response).to receive(:body).and_return(error_body.to_json)
        expect { described_class.new(response).process! }.to raise_error(Marketo::Rails::Errors::TemporaryAPIError)
      end

      it 'raises RuntimeAPIError when an untracked error code is received' do
        response = Net::HTTPSuccess.new(1.0, '200', 'OK')
        error_body[:errors] << { code: 'foo' }
        allow(response).to receive(:body).and_return(error_body.to_json)
        expect { described_class.new(response).process! }.to raise_error(Marketo::Rails::Errors::RuntimeAPIError)
      end
    end
  end

  context '#process_single_result!' do
    let(:http_response) { Net::HTTPSuccess.new(1.0, '200', 'OK') }

    before do
      allow(http_response).to receive(:body).and_return({ result: [result] }.to_json)
    end

    context 'response is a success' do
      let(:result) { { foo: 'bar' } }

      it 'uses process! to get the json body' do
        response = described_class.new(http_response)
        expect(response).to receive(:process!).once.and_call_original
        response.process_single_result!
      end

      it 'does not call process! if response has already been processed' do
        response = described_class.new(http_response)
        response.process!
        expect(response).not_to receive(:process!)
        response.process_single_result!
      end

      it 'returns single result from batch API response' do
        response = described_class.new(http_response)
        expect(response.process_single_result!).to eq(result)
      end
    end

    context 'response is a failure' do
      let(:result) { { status: 'skipped', reasons: [{ message: 'foo', code: 100 }] } }

      it 'raises BadAPIRequest if response contains a skipped status' do
        response = described_class.new(http_response)
        expect { response.process_single_result! }.to raise_error(Marketo::Rails::Errors::BadAPIRequest, 'foo (100)')
      end
    end
  end
end
