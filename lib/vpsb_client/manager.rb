require 'io/console'
require 'logger'

require "#{VPSB_BASE_PATH}/vpsb_client/metrics/manager"
require "#{VPSB_BASE_PATH}/vpsb_client/client/upload_metrics"

module VpsbClient
  class Manager
    attr_reader :http_client, :logger, :config

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
      @signed_in = true
      http_response
    end

    def signed_in?
      return @signed_in if @signed_in
      id_request = Api::GetItemIdRequest.new(@http_client, 'hosters', 'linode')
      curl_response = id_request.run

      begin
        http_response = Api::Response.new(curl_response)
      rescue Api::Response::NotAuthenticated => e
        return @signed_in = false
      end
      @signed_in = true
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

    def csrf_token_block
      Proc.new { csrf_token }
    end

    def create_trial
      unless enabled?
        VpsbClient.logger.debug "not running because vpsb_client is disabled"
        return
      end

      builder = Builders::Trial.new(@config, hoster_id, application_id, plan_id)
      create_trial_request = Api::CreateTrialRequest.new(@http_client, builder.create_params, csrf_token)
      curl_response = create_trial_request.run
      http_response = Api::Response.new(curl_response)
      Api::CreateTrialRequest.trial(http_response)
    end

    def current_trial
      builder = Builders::Trial.new(@config)
      current_trial_request = Api::GetCurrentTrialRequest.new(@http_client, builder.lookup_params)
      curl_response = current_trial_request.run
      http_response = Api::Response.new(curl_response)
      Api::GetCurrentTrialRequest.trial(http_response)
    end

    def trial_last_metric_started_at(trial_id, length)
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

    include Client::UploadMetrics

    def close_trial(trial)
      unless enabled?
        logger.debug "[vpsb] not running because vpsb_client is disabled"
        return
      end

      prepare_logfiles
      
      metric_ids = []
      interval_length = 604800
      last_started_at = trial_last_metric_started_at(trial['id'], interval_length)
      if last_started_at
        start_time = last_started_at + interval_length
      else
        logger.debug "[vpsb] close_trial - no last metric found"
        start_time = Time.now - interval_length
      end
      logger.debug "[vpsb] close_trial - length=#{interval_length} start_time=#{start_time} force=false"
      interval_config = Metrics::IntervalConfig.new(start_time, interval_length, force: true)
      metrics_manager = metrics_manager(trial['id'], interval_config)
      metrics_manager.run
      metric_ids += metrics_manager.created_metric_ids
      logger.debug "[vpsb] Created metric ids: #{metric_ids.inspect}"

      close_request = Api::CloseTrialRequest.new(@http_client, trial['id'], csrf_token)
      http_response = Api::Response.new(close_request.run)
      logger.debug "[vpsb] close request response code = #{http_response.code}"
      http_response
    end

    private

    def prepare_logfiles
      sar_manager = Datafiles::SarManager.new(@config['sar_path'], @config['formatted_sar_path'])
      sar_manager.run

      logfile_decompressor = Datafiles::LogfileDecompressor.new(@config['timing_path'], @config['timing_path'], :filename_prefix => 'timings')
      logfile_decompressor.run
    end


    def metrics_manager(trial_id, interval_config)
      min_start_time = interval_config.min_start_time
      builder         = Metrics::IntervalBuilder.new(@config['formatted_sar_path'], @config['timing_path'], min_start_time, interval_config.length)
      uploader        = Metrics::Uploader.new(@http_client, csrf_token_block, trial_id)

      Metrics::Manager.new(builder, uploader, interval_config)
    end

  end
end
