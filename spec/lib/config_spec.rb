require 'spec_helper'
#require File.join(File.dirname(__FILE__), '..', 'support/lib/timing_log')

module VpsbClient
  data_dir = File.join(File.dirname(__FILE__), '..', 'support/logfiles')

  describe Config do
    before :each do
      support_dir = File.join(File.dirname(__FILE__), '..', 'support/')
      @config = Config.new("#{support_dir}/vpsb.yml")
    end

    it 'parses the config file' do
      expect(@config.value('vpsb_host')).to eq('localhost')
    end

    it 'raises an exception for non existent keys' do
      expect{@config.value('foobar')}.to raise_error
    end

    it 'understands []' do
      expect{@config.value('vpsb_host')}.to_not raise_error
    end

  end
end
