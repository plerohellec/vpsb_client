#!/usr/bin/env ruby

require 'awesome_print'
require File.expand_path('../../lib/vpsb_client',  __FILE__)

manager = VpsbClient::Manager.new(File.expand_path('../../config/vpsb.yml',  __FILE__))
manager.setup

trial = manager.current_trial
unless trial
  puts "Current trial not found"
  exit 1
end

trial_id = trial['id']
puts "trial_id=#{trial_id}"

ap manager.start_old_web_test(trial_id)

