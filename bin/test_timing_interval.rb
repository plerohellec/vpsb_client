#!/usr/bin/env ruby

require_relative '../lib/vpsb_client'

logfile = LogfileInterval::Logfile.new('timings.log.2', VpsbClient::Datafiles::TimingLogParser)

builder = LogfileInterval::IntervalBuilder.new(logfile, VpsbClient::Datafiles::TimingLogParser, 600)
builder.each_interval do |interval|
  next unless interval.size > 0

  if interval[:resptime_total_ms] > interval[:pxx_total_ms][95]
    puts
    puts "start time of interval:               #{interval.start_time}"
    puts "number of requests found in interval: #{interval.size}"
    puts "average total ms                      #{interval[:resptime_total_ms]}"
    puts "p95 total ms                          #{interval[:pxx_total_ms][95]}"
  end
end
