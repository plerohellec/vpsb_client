module VpsbClient
  module Api
    class GetCsrfTokenRequest < GetRequest
      def initialize(http_client, url_path)
        super(http_client)
        @url_path = url_path
      end

      def url_path
        @url_path
      end

      def accept
        'text/html'
      end

      def self.csrf_token(http_response)
        regex = /<meta name="csrf-token" content=\"(?<token>[^\"]+)" \/>/
        if match_data = http_response.body_str.match(regex)
          match_data[:token]
        else
          raise RuntimeError, "CSRF token not found"
        end
      end
    end
  end
end
