module VpsbClient
  module Request
    class Request
      def initialize(http_client)
        @http_client = http_client
      end

      def query_params
        raise NotImplemented
      end

      def post_params
        raise NotImplemented
      end
    end

    class GetRequest < Request
      def run
        @http_client.get(self)
      end
    end

    class PostRequest < Request
      def run
        @http_client.post(self)
      end
    end
  end
end