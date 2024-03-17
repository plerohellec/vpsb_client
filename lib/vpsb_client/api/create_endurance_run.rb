module VpsbClient
  module Api
    class CreateEnduranceRun < PostRequest

      def initialize(http_client, trial_id, num_processors, short_endurance: false)
        super(http_client)
        @trial_id = trial_id
        @num_processors = num_processors
        @short_endurance = short_endurance
      end

      def url_path
        "/api/trials/#{@trial_id}/endurance_runs"
      end

      def post_params
        @post_params = {
          num_processors: @num_processors,
          short_endurance: @short_endurance
        }
      end

      def content_type
        'application/json'
      end
    end
  end
end
