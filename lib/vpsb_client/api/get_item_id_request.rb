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
        "/admin/#{@item_type}/by_name/#{ERB::Util.url_encode(@name)}"
      end

      def self.item_id(http_response)
        http_response.parsed_response['id']
      end
    end
  end
end
