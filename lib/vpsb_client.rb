vpsb_base = File.expand_path('..',  __FILE__)

require "#{vpsb_base}/vpsb_client/version"
require "#{vpsb_base}/vpsb_client/config"
require "#{vpsb_base}/vpsb_client/http_client"
require "#{vpsb_base}/vpsb_client/manager"
require "#{vpsb_base}/vpsb_client/api/request"
require "#{vpsb_base}/vpsb_client/api/response"
require "#{vpsb_base}/vpsb_client/api/get_current_trial_request"
require "#{vpsb_base}/vpsb_client/api/get_item_id_request"
require "#{vpsb_base}/vpsb_client/api/get_csrf_token_request"
require "#{vpsb_base}/vpsb_client/api/signin_request"

module VpsbClient
end
