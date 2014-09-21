#!/usr/bin/env ruby

require File.expand_path('../../lib/vpsb_client',  __FILE__)

manager = VpsbClient::Manager.new(File.expand_path('../../config/vpsb.yml',  __FILE__))
manager.setup

puts "csrf token=#{manager.csrf_token}"

trial_id = manager.current_trial

interval = {}
interval[:duration_seconds] = 3600
interval[:started_at] = Time.now - 3600
interval[:ended_at] = Time.now
interval[:p50_total_ms] = 1
interval[:p75_total_ms] = 1
interval[:p95_total_ms] = 1
interval[:p99_total_ms] = 1
interval[:p75_iowait_pct] = 1
interval[:p95_iowait_pct] = 1
interval[:p99_iowait_pct] = 1
interval[:p75_cpusteal_pct] = 1
interval[:p95_cpusteal_pct] = 1
interval[:p99_cpusteal_pct] = 1
interval[:p75_cpuidle_pct] = 1
interval[:p95_cpuidle_pct] = 1
interval[:p99_cpuidle_pct] = 1

upload_request = VpsbClient::Api::PostMetricRequest.new(manager.http_client, trial_id, interval, manager.csrf_token)
http_response = VpsbClient::Api::Response.new(upload_request.run)
metric_id = VpsbClient::Api::PostMetricRequest.metric_id(http_response)
puts metric_id
