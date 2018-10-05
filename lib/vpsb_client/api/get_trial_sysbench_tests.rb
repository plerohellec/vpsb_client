module VpsbClient
  module Api
    class GetTrialSysbenchTests < GetRequest
      def initialize(http_client, params)
        super(http_client)
        @trial_id = params[:trial_id]
        @sysbench_version = params[:sysbench_version]
        @dev = params[:dev]
      end

      def url_path
        "/api/trials/#{@trial_id}/sysbench_tests"
      end

      def query_params
        h = {
          sysbench_version: @sysbench_version
        }
        h[:dev] = @dev if @dev
        h
      end

      def self.tests(http_response)
        return [] if http_response.parsed_response.empty?
        http_response.parsed_response
      end
    end
  end
end
