require 'io/console'
require 'logger'

require File.join(File.expand_path('..', __FILE__), 'metrics_uploader')

module VpsbClient
  class Manager
    attr_reader :http_client

    class LastMetricNotFoundError < StandardError; end

    def initialize(config_path, logger=Logger.new(STDOUT))
      @config_path = config_path
      @logger = logger
    end

    def setup
      VpsbClient.logger = @logger
      @config = Config.new(@config_path)
      @curl_wrapper = CurlWrapper.new(@config['cookie_jar_path'])
      @http_client = HttpClient.new(@curl_wrapper, @config['vpsb_protocol'], @config['vpsb_hostname'])
    end

    def enabled?
      @config.fetch(:enabled, false)
    end

    def signin(password=nil)
      unless password || @config[:password]
        VpsbClient.logger.debug "No password found"
        return
      end

      password ||= @config[:password]

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
      csrf_token = Api::GetCsrfTokenRequest.csrf_token(curl_response)
      @csrf_token = csrf_token if signed_in? # the token changes after signin
      csrf_token
    end

    def create_trial
      unless enabled?
        VpsbClient.logger.debug "not running because vpsb_client is disabled"
        return
      end

      builder = Builders::Trial.new(@config, hoster_id, application_id, plan_id)
      create_trial_request = Api::CreateTrialRequest.new(@http_client, builder.params, csrf_token)
      curl_response = create_trial_request.run
      http_response = Api::Response.new(curl_response)
      Api::CreateTrialRequest.trial(http_response)
    end

    def current_trial
      builder = Builders::Trial.new(@config, hoster_id, application_id, plan_id)
      create_trial_request = Api::CreateTrialRequest.new(@http_client, builder.params, csrf_token)
      curl_response = current_trial_request.run
      http_response = Api::Response.new(curl_response)
      Api::GetCurrentTrialRequest.trial(http_response)
    end

    def trial_last_metric(trial_id, length)
      current_trial_request = Api::GetTrialLastMetricRequest.new(@http_client, { trial_id: trial_id, length: length})
      curl_response = current_trial_request.run
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

    def upload_metrics(trial)
      unless enabled?
        logger.debug "not running because vpsb_client is disabled"
        return
      end

      sar_manager = Datafiles::SarManager.new(@config['sar_path'], @config['formatted_sar_path'])
      sar_manager.run

      metric_ids = []
      [ 10*60, 3600, 86400 ].each do |len|
        last_started_at = trial_last_metric(trial['id'], len)
        uploader = MetricsUploader.new(@config, @http_client, trial, len, last_started_at, csrf_token)
        uploader.upload
        metric_ids += uploader.created_metric_ids
      end
      metric_ids
    end

  end
end
