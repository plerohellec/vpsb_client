module VpsbClient
  module Api
    class CreateTransfer < PostRequest

      def initialize(http_client, trial_id, server, latency_ms, download_size_bytes, download_duration_ms, upload_size_bytes, upload_duration_ms)
        super(http_client)
        @trial_id = trial_id
        @server = server
        @latency_ms = latency_ms
        @download_size_bytes = download_size_bytes
        @download_duration_ms = download_duration_ms
        @upload_size_bytes = upload_size_bytes
        @upload_duration_ms = upload_duration_ms
      end

      def url_path
        "/api/trials/#{@trial_id}/transfers"
      end

      def post_params
        @post_params = {
          transfer: {
            server: @server,
            latency_ms: @latency_ms,
            download_size_bytes: @download_size_bytes,
            download_duration_ms: @download_duration_ms,
            upload_size_bytes: @upload_size_bytes,
            upload_duration_ms: @upload_duration_ms
          }
        }
      end

      def content_type
        'application/json'
      end
    end
  end
end
