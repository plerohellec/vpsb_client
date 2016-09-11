module VpsbClient
  module Api
    class PostSysbenchRun < PostRequest

      def initialize(http_client, trial_id, test_id, command, data)
        super(http_client)
        @trial_id = trial_id
        @test_id = test_id
        @command = command
        @data = data
      end

      def url_path
        "/api/trials/#{@trial_id}/sysbench_runs"
      end

      def post_params
        @post_params = { sysbench_run: {
            test_id: @test_id,
            command: @command,
            data: @data
          }
        }
      end

      def content_type
        'application/json'
      end
    end
  end
end
