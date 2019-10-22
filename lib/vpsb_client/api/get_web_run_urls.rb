require 'date'

module VpsbClient
  module Api
    class GetWebRunUrls < GetRequest
      def initialize(http_client, params)
        super(http_client)
        @dataset = params[:dataset]
      end

      def url_path
        "/api/web_runs/urls/#{@dataset}"
      end

      def self.urls(http_response)
        http_response.body_str
      end
    end
  end
end
