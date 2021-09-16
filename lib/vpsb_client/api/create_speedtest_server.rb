module VpsbClient
  module Api
    class CreateSpeedtestServer < PostRequest

      def initialize(http_client, params)
        super(http_client)
        @hostname = params[:hostname]
        @port = params[:port]
        @event = params[:event]
      end

      def url_path
        "/api/speedtest_servers"
      end

      def post_params
        @post_params = {
          hostname: @hostname,
          port: @port,
          event: @event
        }
      end

      def content_type
        'application/json'
      end
    end
  end
end
