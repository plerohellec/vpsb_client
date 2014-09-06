module VpsbClient
  module Api
    class SigninRequest < PostRequest
      def initialize(http_client, email, password, csrf_token)
        super(http_client, csrf_token)
        @email = email
        @password = password
      end

      def url_path
        "/users/sign_in"
      end

      def post_params
        { 'user[email]' => @email,
          'user[password]' => @password
        }
      end

      def accept
        'text/html'
      end
    end
  end
end
