module VpsbClient
  module Api
    class CreateFioTest < PostRequest
      def initialize(http_client, attributes)
        super(http_client)
        @attributes = attributes
      end

      def url_path
        '/api/fio_tests'
      end

      def post_params
        { fio_test: @attributes }
      end

      def content_type
        'application/json'
      end
    end
  end
end