#!/usr/bin/env ruby

require File.expand_path('../../lib/vpsb_client',  __FILE__)

manager = VpsbClient::Manager.new(File.expand_path('../../config/vpsb.yml',  __FILE__))
manager.setup

t = manager.create_trial
if t
  puts "new trial = #{t.inspect}"
else
  puts "no trial was created"
end
