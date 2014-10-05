vpsb_base = File.expand_path('..',  __FILE__)

require "#{vpsb_base}/vpsb_client/version"
require "#{vpsb_base}/vpsb_client/config"
require "#{vpsb_base}/vpsb_client/http_client"
require "#{vpsb_base}/vpsb_client/curl_wrapper"
require "#{vpsb_base}/vpsb_client/manager"
require "#{vpsb_base}/vpsb_client/api/request"
require "#{vpsb_base}/vpsb_client/api/response"
require "#{vpsb_base}/vpsb_client/api/get_current_trial_request"
require "#{vpsb_base}/vpsb_client/api/get_trial_last_metric_request"
require "#{vpsb_base}/vpsb_client/api/get_item_id_request"
require "#{vpsb_base}/vpsb_client/api/get_csrf_token_request"
require "#{vpsb_base}/vpsb_client/api/signin_request"
require "#{vpsb_base}/vpsb_client/api/create_trial_request"
require "#{vpsb_base}/vpsb_client/api/post_metric_request"
require "#{vpsb_base}/vpsb_client/builders/system_info_parser"
require "#{vpsb_base}/vpsb_client/builders/trial"
require "#{vpsb_base}/vpsb_client/builders/metrics_interval"
require "#{vpsb_base}/vpsb_client/datafiles/sar_manager"

module VpsbClient
end
