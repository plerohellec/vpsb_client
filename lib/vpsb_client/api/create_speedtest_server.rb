module VpsbClient
  module Api
    class CreateSpeedtestServer < PostRequest

      def initialize(http_client, params)
        super(http_client)
        @hostname = params[:hostname]
        @port = params[:port]
        @event = params[:event]
        @latitude = params[:latitude]
        @longitude = params[:longitude]
      end

      def url_path
        "/api/speedtest_servers"
      end

      def post_params
        @post_params = {
          hostname: @hostname,
          port: @port,
          event: @event,
        }
        @post_params[:latitude] = @latitude if @latitude
        @post_params[:longitude] = @longitude if @longitude
        @post_params
      end

      def content_type
        'application/json'
      end
    end
  end
end
