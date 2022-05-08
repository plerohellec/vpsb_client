module VpsbClient
  module Api
    class CreateYab < PostRequest

      def initialize(http_client, trial_id, yabs_out)
        super(http_client)
        @trial_id = trial_id
        @data = yabs_out
      end

      def url_path
        "/api/trials/#{@trial_id}/yabs"
      end

      def post_params
        @post_params = {
          data: @data
        }
      end

      def content_type
        'application/json'
      end
    end
  end
end
