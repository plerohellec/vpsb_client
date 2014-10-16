require 'spec_helper'

module VpsbClient
  describe MetricsUploader do
    describe :upload do
      before :each do
        VpsbClient.logger = Logger.new('/dev/null')
        @curl = double('curl')
        @client = HttpClient.new(@curl, 'http', 'localhost')
        @csrf_token = 'abc'
        @trial_id = 1
        @start = Time.new(2014, 10, 15, 20, 0, 0)
        @last_interval_started_at = @start
        @trial = { 'id' => @trial_id, 'started_at' => @last_interval_started_at }
        @len = 3600
        @config = { 'formatted_sar_path' => '', 'timing_path' => '' }
      end

      it 'posts once for each interval' do
        @metric_params = { metric: {started_at: @start + @len, duration_seconds: @len, trial_id: @trial_id},
                           authenticity_token: @csrf_token }

        curl_response = double('response')
        allow(curl_response).to receive(:response_code).and_return(200)
        allow(curl_response).to receive(:body_str).and_return('{"id": 8}')
        allow(curl_response).to receive(:content_type).and_return("application/json")
        expect(@curl).to receive(:post).with('http://localhost/admin/metrics.json',
                                             @metric_params.to_json,
                                             "application/json").once.and_return(curl_response)
        interval1 = { :started_at => @start + @len, :duration_seconds => @len }
        allow(Time).to receive(:now).and_return(@start + 2 * @len)
        allow_any_instance_of(Builders::MetricsInterval).to receive(:each).and_yield(interval1)

        uploader = MetricsUploader.new(@config, @client, @trial, @len, @last_interval_started_at, @csrf_token)
        uploader.upload
      end

      it 'does no compute intervals when it is too early' do
        expect(Builders::MetricsInterval).to receive(:new).never
        allow(Time).to receive(:now).and_return(@start + 0.9 * @len)
        uploader = MetricsUploader.new(@config, @client, @trial, @len, @last_interval_started_at, @csrf_token)
        uploader.upload
      end
    end
  end
end