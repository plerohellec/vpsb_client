#!/usr/bin/env ruby

require '/home/philippe/src/plerohellec/vpsb_client/lib/vpsb_client'

m = VpsbClient::Manager.new '/home/philippe/src/plerohellec/vpsb_client/config/vpsb.yml'
m.setup
puts m.hoster_id
puts m.application_id
puts m.plan_id
