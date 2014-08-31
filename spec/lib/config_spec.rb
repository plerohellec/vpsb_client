require 'spec_helper'
#require File.join(File.dirname(__FILE__), '..', 'support/lib/timing_log')

module VpsbClient
  data_dir = File.join(File.dirname(__FILE__), '..', 'support/logfiles')

  describe Config do
    before :each do
      @config = Config.new(
    end

    it 'gets instantiated with empty data' do
    end
  end
end
