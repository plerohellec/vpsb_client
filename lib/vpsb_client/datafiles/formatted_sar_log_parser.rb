require 'logfile_interval'
require File.join(File.expand_path('..',  __FILE__), 'pxx_aggregator')

module VpsbClient
  module Datafiles
    class FormattedSarLogParser < LogfileInterval::ParsedLine::Base

      # # hostname;interval;timestamp;CPU;%user;%nice;%system;%iowait;%steal;%idle
      # lino;300;1394780701;-1;4.19;0.00;0.40;0.87;5.49;89.05
      set_regex /^\S+;\S+;(?<ts>\d+);\S+;(?<user>[\d\.]+);(?<nice>[\d\.]+);(?<system>[\d\.]+);(?<iowait>[\d\.]+);(?<steal>[\d\.]+);(?<idle>[\d\.]+)$/

      PXX_RANGES = {
        1  => 0.02,
        10 => 0.1,
        20 => 0.5,
        100 => 1
      }

      add_column :name => 'timestamp', :pos => 1, :aggregator => :timestamp
      add_column :name => 'user',      :pos => 2, :aggregator => :average, :conversion => :float
      add_column :name => 'nice',      :pos => 3, :aggregator => :average, :conversion => :float
      add_column :name => 'system',    :pos => 4, :aggregator => :average, :conversion => :float
      add_column :name => 'iowait',    :pos => 5, :aggregator => :average, :conversion => :float
      add_column :name => 'pxx_iowait',    :pos => 5, :aggregator => :pxx, :conversion => :float,
                    :custom_options => { :ranges => PXX_RANGES, :pxx_keys => [ 75, 95, 99 ] }
      add_column :name => 'cpu_steal',     :pos => 6, :aggregator => :average, :conversion => :float
      add_column :name => 'pxx_cpusteal', :pos => 6, :aggregator => :pxx,     :conversion => :float,
                    :custom_options => { :ranges => PXX_RANGES, :pxx_keys => [ 75, 95, 99 ] }
      add_column :name => 'cpu_idle',      :pos => 7, :aggregator => :average, :conversion => :float
      add_column :name => 'pxx_cpuidle',  :pos => 7, :aggregator => :one_hundred_minus_pxx, :conversion => :float,
                    :custom_options => { :ranges => PXX_RANGES, :pxx_keys => [ 75, 95, 99 ] }

      def time
        Time.at(self.timestamp.to_i)
      end
    end
  end
end
