require 'spec_helper'
#require File.join(File.dirname(__FILE__), '..', 'support/lib/timing_log')

module VpsbClient
  describe Config do
    before :each do
      support_dir = File.join(File.dirname(__FILE__), '..', 'support/')
      @config = Config.new("#{support_dir}/vpsb.yml")
    end

    it 'parses the config file' do
      expect(@config.fetch('vpsb_hostname')).to eq('localhost:3000')
    end

    it 'raises an exception for non existent keys' do
      expect{@config.fetch('foobar')}.to raise_error(KeyError)
    end

    it 'understands []' do
      expect{@config['vpsb_hostname']}.to_not raise_error
    end

    it 'fetch_optional does not raise exception for missing param' do
      expect{@config.fetch_optional('missing')}.to_not raise_error
    end
  end
end
