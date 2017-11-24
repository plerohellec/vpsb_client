#!/usr/bin/env ruby

require File.expand_path('../../lib/vpsb_client',  __FILE__)

manager = VpsbClient::Manager.new(File.expand_path('../../config/vpsb.yml',  __FILE__))
manager.setup

t = manager.create_endurance_run(ENV.fetch('TRIAL_ID', 1), 5)
if t
  puts "new endurance run = #{t.parsed_response.inspect}"
else
  puts "no endurance run was created"
end
