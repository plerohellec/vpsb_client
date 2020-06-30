#!/usr/bin/env ruby

require File.expand_path('../../lib/vpsb_client',  __FILE__)

manager = VpsbClient::Manager.new(File.expand_path('../../config/vpsb.yml',  __FILE__))
manager.setup

t = manager.create_transfer(ENV.fetch('TRIAL_ID', 1), "bigserver", 34, 10000, 30000, 1000, 2000, 'httparty')
if t
  puts "new transfer = #{t.parsed_response.inspect}"
else
  puts "no endurance run was created"
end
