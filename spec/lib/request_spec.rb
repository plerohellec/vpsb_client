require 'spec_helper'

module VpsbClient
  module Api
    support_dir = File.join(File.dirname(__FILE__), '..', 'support/')

    describe GetCurrentTrialRequest do
      before :each do
      end

      it 'sends a get request' do
        client = double('client')
        req = GetCurrentTrialRequest.new(client, 1, 2, 3)
        expect(client).to receive(:get).with(req).once
        req.run
      end
    end

    describe GetItemIdRequest do
      it 'url includes item type and name' do
        curl = double('curl')
        client = HttpClient.new(curl, 'http', 'localhost')
        expect(curl).to receive(:get).with('http://localhost/admin/hosters/by_name/linode.json').once

        req = GetItemIdRequest.new(client, 'hosters', 'linode')
        req.run
      end
    end

  end
end
