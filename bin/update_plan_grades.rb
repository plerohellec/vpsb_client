#!/usr/bin/env ruby

require 'awesome_print'
require File.expand_path('../../lib/vpsb_client',  __FILE__)

manager = VpsbClient::Manager.new(File.expand_path('../../config/vpsb.yml',  __FILE__))
manager.setup

response = manager.update_plan_grades
puts "code = #{response.code}"
