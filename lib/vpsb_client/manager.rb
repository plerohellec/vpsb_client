require 'io/console'

module VpsbClient
  class Manager
    attr_reader :http_client

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

    def current_trial
      builder = Builders::Trial.new(hoster_id, application_id, plan_id, @config['comment'])
      current_trial_request = Api::GetCurrentTrialRequest.new(@http_client, builder.params)
      curl_response = current_trial_request.run
      puts curl_response.body
      http_response = Api::Response.new(curl_response)
      Api::GetCurrentTrialRequest.trial_id(http_response)
    end

    def trial_last_metric(trial_id, length)
      current_trial_request = Api::GetTrialLastMetricRequest.new(@http_client, { trial_id: trial_id, length: length})
      curl_response = current_trial_request.run
      puts curl_response.body
      http_response = Api::Response.new(curl_response)
      Api::GetTrialLastMetricRequest.started_at(http_response)
    end

    def hoster_id
      return @hoster_id if @hoster_id
      id_request = Api::GetItemIdRequest.new(@http_client, 'hosters', @config['hoster_name'])
      http_response = Api::Response.new(id_request.run)
      id = Api::GetItemIdRequest.item_id(http_response)
      raise NameError, "#{@config['hoster_name']} hoster not found" unless id
      @hoster_id = id
    end

    def application_id
      return @application_id if @application_id
      id_request = Api::GetItemIdRequest.new(@http_client, 'applications', @config['application_name'])
      http_response = Api::Response.new(id_request.run)
      id = Api::GetItemIdRequest.item_id(http_response)
      raise NameError, "#{@config['application_name']} application not found" unless id
      @application_id = id
    end

    def plan_id
      return @plan_id if @plan_id
      id_request = Api::GetPlanIdRequest.new(@http_client, hoster_id, @config['plan_name'])
      http_response = Api::Response.new(id_request.run)
      id = Api::GetPlanIdRequest.item_id(http_response)
      raise NameError, "#{@config['plan_name']} plan not found" unless id
      @plan_id = id
    end

    def upload_metrics
      trial_id = current_trial
      sar_manager = Datafiles::SarManager.new(@config['sar_orig_path'], @config['sar_target_path'])
      sar_manager.run
      metric_ids = []
      [ 10.minutes, 1.hour, 1.day ].each do |len|
        last_started_at = trial_last_metric(trial_id, len)
        builder = Builders::MetricBuilder.new()
        builder.each_interval do |interval|
          upload_request = Api::PostMetricRequest.new(@http_client, trial_id, interval, csrf_token)
          http_response = Api::Response.new(upload_request.run)
          unless http_response.success?
            puts "Failed to upload metric (len=#{len} interval=#{interval.inspect})"
            break
          end
          metric_ids << Api::PostMetricRequest.metric_id(http_response)
        end
      end
    end
  end
end
