#!/usr/bin/env ruby

require File.expand_path('../../lib/vpsb_client',  __FILE__)

manager = VpsbClient::Manager.new(File.expand_path('../../config/vpsb.yml',  __FILE__))
manager.setup

puts manager.trial_last_metric_started_at(22, 3600)
