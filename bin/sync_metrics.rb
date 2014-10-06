#!/usr/bin/env ruby

require 'awesome_print'
require File.expand_path('../../lib/vpsb_client',  __FILE__)

manager = VpsbClient::Manager.new(File.expand_path('../../config/vpsb.yml',  __FILE__))
manager.setup

puts "csrf token=#{manager.csrf_token}"

trial_id = manager.current_trial
unless trial_id
  puts "Cannot find current trial"
  exit 1
end

metric_ids = manager.upload_metrics

