require 'erb'

module VpsbClient
  module Api
    class GetItemIdRequest < GetRequest
      def initialize(http_client, item_type, name)
        super(http_client)
        @item_type = item_type
        @name = name
      end

      def url_path
        "/api/#{@item_type}/by_name/#{ERB::Util.url_encode(@name)}"
      end

      def self.item_id(http_response)
        return nil unless http_response.parsed_response.any?
        http_response.parsed_response.first['id']
      end
    end

    class GetPlanIdRequest < GetItemIdRequest
      def initialize(http_client, hoster_id, plan_name)
        super(http_client, 'plans', plan_name)
        @hoster_id = hoster_id
      end

      def query_params
        { hoster_id: @hoster_id }
      end
    end
  end
end
