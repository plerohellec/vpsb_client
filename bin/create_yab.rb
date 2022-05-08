#!/usr/bin/env ruby

require File.expand_path('../../lib/vpsb_client',  __FILE__)

manager = VpsbClient::Manager.new(File.expand_path('../../config/vpsb.yml',  __FILE__))
manager.setup

yab_out_filename = ENV.fetch('YAB_OUT_FILENAME')
yab = manager.create_yab(ENV.fetch('TRIAL_ID', 1), File.read(yab_out_filename))
if yab
  puts "new yab = #{yab.parsed_response.inspect}"
else
  puts "no yab was created"
end

