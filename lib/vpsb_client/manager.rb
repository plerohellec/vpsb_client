require 'io/console'

module VpsbClient
  class Manager
    def initialize(config_path)
      @config_path = config_path
    end

    def setup
      @config = Config.new(@config_path)
      @curl_wrapper = CurlWrapper.new(@config['cookie_jar_path'])
      @http_client = HttpClient.new(@curl_wrapper, @config['protocol'], @config['hostname'])
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
      url_path = signed_in? ? '/admin/plans' : '/users/sign_in'

      get_csrf_request = Api::GetCsrfTokenRequest.new(@http_client, url_path)
      curl_response = get_csrf_request.run
      @csrf_token = Api::GetCsrfTokenRequest.csrf_token(curl_response)
    end

    def create_trial
      builder = Builders::Trial.new(hoster_id, application_id, plan_id, @config['comment'])
      create_trial_request = Api::CreateTrialRequest.new(@http_client, builder.params, csrf_token)
      curl_response = create_trial_request.run
      http_response = Api::Response.new(curl_response)
      Api::CreateTrialRequest.trial_id(http_response)
    end

    def hoster_id
      return @hoster_id if @hoster_id
      id_request = Api::GetItemIdRequest.new(@http_client, 'hosters', @config['hoster_name'])
      http_response = Api::Response.new(id_request.run)
      @hoster_id = Api::GetItemIdRequest.item_id(http_response)
    end

    def application_id
      return @application_id if @application_id
      id_request = Api::GetItemIdRequest.new(@http_client, 'applications', @config['application_name'])
      http_response = Api::Response.new(id_request.run)
      @application_id = Api::GetItemIdRequest.item_id(http_response)
    end

    def plan_id
      return @plan_id if @plan_id
      id_request = Api::GetPlanIdRequest.new(@http_client, hoster_id, @config['plan_name'])
      http_response = Api::Response.new(id_request.run)
      @plan_id = Api::GetPlanIdRequest.item_id(http_response)
    end
  end
end
