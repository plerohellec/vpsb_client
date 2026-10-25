module VpsbClient
  module Api
    class GetNextFioTest < GetRequest
      def initialize(http_client, trial_id)
        super(http_client)
        @trial_id = trial_id
      end

      def url_path
        '/api/fio_tests/next_test'
      end

      def query_params
        { trial_id: @trial_id }
      end
    end
  end
end