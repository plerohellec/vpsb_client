require 'spec_helper'
#require File.join(File.dirname(__FILE__), '..', 'support/lib/timing_log')

module VpsbClient
  module Request
    support_dir = File.join(File.dirname(__FILE__), '..', 'support/')

    describe GetCurrentTrial do
      before :each do
	@http_client = double('client')
	config = Config.new("#{support_dir}/vpsb.yml")

	@request = GetCurrentTrial.new(@http_client, 1, 2, 3)
      end

      it 'sends a get request' do
	expect(@http_client).to receive(:get).once
        expect(@request).to receive(:query_params).once
        @request.run
      end
    end
  end
end
