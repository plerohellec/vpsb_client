VPSB_BASE_PATH = File.expand_path('..',  __FILE__)

require "#{VPSB_BASE_PATH}/vpsb_client/version"
require "#{VPSB_BASE_PATH}/vpsb_client/config"
require "#{VPSB_BASE_PATH}/vpsb_client/http_client"
require "#{VPSB_BASE_PATH}/vpsb_client/curl_wrapper"
require "#{VPSB_BASE_PATH}/vpsb_client/manager"
require "#{VPSB_BASE_PATH}/vpsb_client/api/request"
require "#{VPSB_BASE_PATH}/vpsb_client/api/response"
require "#{VPSB_BASE_PATH}/vpsb_client/api/get_current_trial_request"
require "#{VPSB_BASE_PATH}/vpsb_client/api/get_trial_last_metric_request"
require "#{VPSB_BASE_PATH}/vpsb_client/api/get_trial_sysbench_tests"
require "#{VPSB_BASE_PATH}/vpsb_client/api/post_sysbench_run"
require "#{VPSB_BASE_PATH}/vpsb_client/api/get_item_id_request"
require "#{VPSB_BASE_PATH}/vpsb_client/api/create_trial_request"
require "#{VPSB_BASE_PATH}/vpsb_client/api/post_metric_request"
require "#{VPSB_BASE_PATH}/vpsb_client/api/close_trial_request"
require "#{VPSB_BASE_PATH}/vpsb_client/api/create_endurance_run"
require "#{VPSB_BASE_PATH}/vpsb_client/api/create_transfer"
require "#{VPSB_BASE_PATH}/vpsb_client/api/close_endurance_run"
require "#{VPSB_BASE_PATH}/vpsb_client/api/create_endurance_metric"
require "#{VPSB_BASE_PATH}/vpsb_client/api/update_plan_grades"
require "#{VPSB_BASE_PATH}/vpsb_client/api/get_web_run_last_metric"
require "#{VPSB_BASE_PATH}/vpsb_client/api/get_web_run_missing_types"
require "#{VPSB_BASE_PATH}/vpsb_client/api/create_web_run"
require "#{VPSB_BASE_PATH}/vpsb_client/api/append_web_run_metrics"
require "#{VPSB_BASE_PATH}/vpsb_client/api/close_web_run"
require "#{VPSB_BASE_PATH}/vpsb_client/builders/system_info_parser"
require "#{VPSB_BASE_PATH}/vpsb_client/builders/trial"
require "#{VPSB_BASE_PATH}/vpsb_client/datafiles/sar_manager"
require "#{VPSB_BASE_PATH}/vpsb_client/datafiles/logfile_decompressor"

module VpsbClient
  def self.logger=(logger)
    @@logger = logger
  end

  def self.logger
    if defined?(@@logger)
      @@logger
    else
      @@logger = Logger.new('/dev/null')
    end
  end
end
