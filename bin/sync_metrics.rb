#!/usr/bin/env ruby

require 'awesome_print'
require File.expand_path('../../lib/vpsb_client',  __FILE__)

manager = VpsbClient::Manager.new(File.expand_path('../../config/vpsb.yml',  __FILE__))
manager.setup

trial_id = manager.current_trial['id']
unless trial_id
  puts "Cannot find current trial"
  exit 1
end
puts "trial_id=#{trial_id}"

trial = manager.current_trial
metric_ids = manager.upload_metrics(trial)
puts "metric_ids=#{metric_ids.inspect}"

