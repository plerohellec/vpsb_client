#!/usr/bin/env ruby

require File.expand_path('../../lib/vpsb_client',  __FILE__)

manager = VpsbClient::Manager.new(File.expand_path('../../config/vpsb.yml',  __FILE__))
manager.setup

puts manager.create_speedtest_server('speedtest.zetabroadband.com', 8080, 'failure', 44.5, 12.9)

