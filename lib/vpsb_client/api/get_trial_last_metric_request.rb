module VpsbClient
  module Api
    class GetTrialLastMetricRequest < GetRequest
      def initialize(http_client, params)
        super(http_client)
        @trial_id = params[:trial_id]
        @length = params[:length]
      end

      def url_path
        "/admin/trials/#{@trial_id}/last_metric"
      end

      def query_params
        { length: @length  }
      end

      def self.started_at(http_response)
        return nil if http_response.parsed_response.empty?
        metric = http_response.parsed_response.first
        DateTime.parse(metric['started_at']).to_time
      end
    end
  end
end
