module VpsbClient
  module Request

    class Request
      def initialize(http_client)
        @http_client = http_client
      end

      def run
	case method
	when :get
	  then @http_client.get(url_path, query_params)
	when :post
	  then @http_client.post(url_path, query_params, post_params)
	end
      end
    end

    class GetRequest < Request
      def method
	:get
      end
    end

    class PostRequest
      def method
	:post
      end
    end

    class GetCurrentTrial < GetRequest
      def initialize(http_client, application_id, plan_id, hoster_id)
        super(http_client)
        @application_id = application_id
        @plan_id = plan_id
        @hoster_id = hoster_id
      end

      def url_path
	"/admin/trials/current"
      end

      def query_params
	{ hoster_id: @hoster_id,
	  application_id: @application_id,
	  plan_id: @plan_id
	}
      end
    end
  end
end