module VpsbClient
  module Request
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