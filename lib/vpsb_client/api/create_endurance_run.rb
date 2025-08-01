module VpsbClient
  module Api
    class CreateEnduranceRun < PostRequest

      def initialize(http_client, trial_id, num_processors, duration_key: 'long')
        super(http_client)
        @trial_id = trial_id
        @num_processors = num_processors
        @duration_key = duration_key
      end

      def url_path
        "/api/trials/#{@trial_id}/endurance_runs"
      end

      def post_params
        @post_params = {
          num_processors: @num_processors,
          duration_key: @duration_key
        }
      end

      def content_type
        'application/json'
      end
    end
  end
end
