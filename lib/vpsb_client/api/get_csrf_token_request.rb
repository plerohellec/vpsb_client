module VpsbClient
  module Api
    class GetCsrfTokenRequest < GetRequest
      def initialize(http_client)
        super(http_client)
      end

      def url_path
        "/users/sign_in"
      end

      def accept
        'text/html'
      end

      def self.csrf_token(http_response)
        regex = /<meta content=\"(?<token>[^\"]+)" name="csrf-token" \/>/
        if match_data = http_response.body_str.match(regex)
          match_data[:token]
        end
      end
    end
  end
end
