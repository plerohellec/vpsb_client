module VpsbClient
  module Api
    class GetTrialSysbenchTests < GetRequest
      def initialize(http_client, params)
        super(http_client)
        @trial_id = params[:trial_id]
        @sysbench_version = params[:sysbench_version]
      end

      def url_path
        "/api/trials/#{@trial_id}/sysbench_tests"
      end

      def query_params
        {
          sysbench_version: @sysbench_version
        }
      end

      def self.tests(http_response)
        return [] if http_response.parsed_response.empty?
        http_response.parsed_response
      end
    end
  end
end
