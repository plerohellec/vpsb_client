#!/usr/bin/env ruby

require File.expand_path('../../lib/vpsb_client',  __FILE__)

manager = VpsbClient::Manager.new(File.expand_path('../../config/vpsb.yml',  __FILE__))
manager.setup

data = <<DATA
Test execution summary:
    total time:                          7.8366s
    total number of events:              20000
    total time taken by event execution: 31.3283
    per-request statistics:
         min:                                  1.35ms
         avg:                                  1.57ms
         max:                                 21.53ms
         approx.  95 percentile:               1.54ms
DATA

t = manager.create_sysbench_run(1, 'cpu_0_v1', 'sysbench --test=cpu --num-threads=4 --max-requests=20000 run', data)
if t
  puts "new sysbench run = #{t.inspect}"
else
  puts "no run was created"
end
