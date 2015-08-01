require 'spec_helper'

module VpsbClient
  module Metrics
    describe Uploader do
      before :each do
        VpsbClient.logger = Logger.new('/dev/null')
        @curl = double('curl')
        @client = HttpClient.new(@curl, 'http', 'localhost')
        @trial_id = 1
        @start = Time.new(2014, 10, 15, 20, 0, 0)
        @len = 3600
      end

      describe 'upload' do
        before :each do
          @metric = {started_at: @start + @len, duration_seconds: @len, trial_id: @trial_id}
          @metric_params = { metric: @metric }

          @curl_response = double('response')
          allow(@curl_response).to receive(:response_code).and_return(200)
          allow(@curl_response).to receive(:body_str).and_return('{"id": 8}')
          allow(@curl_response).to receive(:content_type).and_return("application/json")
        end

        it 'posts once for each interval' do
          expect(@curl).to receive(:post).with('http://localhost/api/metrics.json',
                                              @metric_params.to_json,
                                              "application/json").once.and_return(@curl_response)

          uploader = Uploader.new(@client, @trial_id)
          uploader.upload(@metric)
        end

        it 'returns the new metric id' do
          allow(@curl).to receive(:post).with('http://localhost/api/metrics.json',
                                              @metric_params.to_json,
                                              "application/json").once.and_return(@curl_response)
          uploader = Uploader.new(@client, @trial_id)
          expect(uploader.upload(@metric)).to eq(8)
        end
      end
    end
  end
end
