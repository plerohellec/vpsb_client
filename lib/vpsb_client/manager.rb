require 'io/console'

module VpsbClient
  class Manager
    def initialize(config_path)
      @config_path = config_path
    end

    def setup
      @config = Config.new(@config_path)
      @http_client = HttpClient.new(@config['protocol'], @config['hostname'], @config['cookie_jar_path'])
    end

    def signin
      puts "Enter password: "
      password = STDIN.noecho(&:gets).chomp

      signin_request = Api::SigninRequest.new(@http_client, @config['email'], password, csrf_token)
      curl_response = signin_request.run
      http_response = Api::Response.new(curl_response)
    end

    def signed_in?
      id_request = Api::GetItemIdRequest.new(@http_client, 'hosters', 'linode')
      curl_response = id_request.run

      begin
        http_response = Api::Response.new(curl_response)
      rescue Api::Response::NotAuthenticated => e
        return false
      end
      true
    end

    def csrf_token
      return @csrf_token if @csrf_token
      get_csrf_request = Api::GetCsrfTokenRequest.new(@http_client)
      curl_response = get_csrf_request.run
      @csrf_token = Api::GetCsrfTokenRequest.csrf_token(curl_response)
    end
  end
end
