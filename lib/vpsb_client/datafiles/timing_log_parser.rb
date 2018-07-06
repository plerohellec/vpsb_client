require 'logfile_interval'
require File.join(File.expand_path('..',  __FILE__), 'pxx_aggregator')

module VpsbClient
  module Datafiles
    class TimingLogParser < LogfileInterval::ParsedLine::Base

      # 1389477034 200 PackagesController#full_url              total=98 view=38.4 db=5.3 ip=66.249.76.30
      set_regex /^(\d+)\s+(\d+)\s([\S]+)\s+total=([\d\.]+)\sview=([\d\.]+)\sdb=([\d\.]+)\sip=([\d\.]+)$/

      PXX_RANGES = {
        100 => 2,
        250 => 5,
        500 => 10,
        1000 => 25,
        3000 => 100
      }

      add_column :name => :timestamp,           :pos => 1, :aggregator => :timestamp
      add_column :name => :resptime_total_ms,   :pos => 4, :aggregator => :average,   :conversion => :float
      add_column :name => :resptime_view_ms,    :pos => 5, :aggregator => :average,   :conversion => :float
      add_column :name => :resptime_db_ms,      :pos => 6, :aggregator => :average,   :conversion => :float
      add_column :name => :num_requests,        :pos => 7, :aggregator => :num_lines
      add_column :name => :pxx_total_ms,        :pos => 4, :aggregator => :pxx,       :conversion => :integer,
                    :custom_options => { :ranges => PXX_RANGES, :pxx_keys => [ 50, 75, 95, 99 ] }

      def time
        Time.at(self.timestamp.to_i)
      end
    end
  end
end
