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
      @curl_wrapper = CurlWrapper.new(@config['auth_token'])
      @http_client = HttpClient.new(@curl_wrapper, @config['vpsb_protocol'], @config['vpsb_hostname'])
    end

    def enabled?
      @config.fetch(:enabled, false)
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

    def create_trial
      unless enabled?
        VpsbClient.logger.debug "not running because vpsb_client is disabled"
        return
      end

      builder = Builders::Trial.new(@config, hoster_id, application_id, plan_id)
      create_trial_request = Api::CreateTrialRequest.new(@http_client, builder.create_params)
      curl_response = create_trial_request.run
      http_response = Api::Response.new(curl_response)
      Api::CreateTrialRequest.trial(http_response)
    end

    def create_sysbench_run(trial_id, test_id, command, data)
      create_sysbench_run_request = Api::PostSysbenchRun.new(@http_client, trial_id, test_id, command, data)
      curl_response = create_sysbench_run_request.run
      http_response = Api::Response.new(curl_response)
    end

    def create_endurance_run(trial_id, num_processors)
      create_endurance_run_request = Api::CreateEnduranceRun.new(@http_client, trial_id, num_processors)
      curl_response = create_endurance_run_request.run
      http_response = Api::Response.new(curl_response)
    end

    def close_endurance_run(trial_id, endurance_run_id)
      close_endurance_run_request = Api::CloseEnduranceRun.new(@http_client, trial_id, endurance_run_id)
      curl_response = close_endurance_run_request.run
      http_response = Api::Response.new(curl_response)
    end

    def create_endurance_metric(trial_id, endurance_run_id, metric_params)
      create_endurance_metric_request = Api::CreateEnduranceMetric.new(@http_client, trial_id, endurance_run_id, metric_params)
      curl_response = create_endurance_metric_request.run
      http_response = Api::Response.new(curl_response)
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

    def trial_sysbench_tests(trial_id)
      trial_sysbench_tests_request = Api::GetTrialSysbenchTests.new(@http_client, trial_id: trial_id)
      curl_response = trial_sysbench_tests_request.run
      http_response = Api::Response.new(curl_response)
      Api::GetTrialSysbenchTests.tests(http_response)
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

      close_request = Api::CloseTrialRequest.new(@http_client, trial['id'])
      http_response = Api::Response.new(close_request.run)
      logger.debug "[vpsb] close request response code = #{http_response.code}"
      http_response
    end

    def update_plan_grades
      update_request = Api::UpdatePlanGrades.new(@http_client)
      http_response = Api::Response.new(update_request.run)
      logger.debug "[vpsb] update plan grades request response code = #{http_response.code}"
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
      uploader        = Metrics::Uploader.new(@http_client, trial_id)

      Metrics::Manager.new(builder, uploader, interval_config)
    end

  end
end
