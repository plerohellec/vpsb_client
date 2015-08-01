module VpsbClient
  module Api
    class Request
      def initialize(http_client)
        @http_client = http_client
      end

      def query_params
        {}
      end

      def post_params
        {}
      end

      def put_params
        {}
      end

      def accept
        'application/json'
      end
    end

    class GetRequest < Request
      def run
        VpsbClient.logger.debug "class=#{self.class} url_path=#{url_path}"
        @http_client.get(self)
      end
    end

    class PostRequest < Request
      def initialize(http_client)
        super(http_client)
      end

      def run
        @http_client.post(self)
      end

      def content_type
        'application/x-www-form-urlencoded'
      end
    end


    class PutRequest < Request
      def initialize(http_client)
        super(http_client)
      end

      def run
        @http_client.put(self)
      end
    end
  end
end