require 'date'

module VpsbClient
  module Api
    class GetWebRunLastMetric < GetRequest
      def initialize(http_client, params)
        super(http_client)
        @trial_id = params[:trial_id]
        @web_run_id = params[:web_run_id]
      end

      def url_path
        "/api/trials/#{@trial_id}/web_runs/#{@web_run_id}/last_metric"
      end

      def self.metric(http_response)
        return nil if http_response.parsed_response.empty?
        http_response.parsed_response
      end
    end
  end
end
