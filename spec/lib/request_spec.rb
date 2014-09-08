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

      it 'parses the response from the server' do
        curl = double('curl')
        client = HttpClient.new(curl, 'http', 'localhost')

        curl_response = double('response')
        allow(curl_response).to receive(:response_code).and_return(200)
        allow(curl_response).to receive(:body_str).and_return('[{"id": 25}]')
        allow(curl_response).to receive(:content_type).and_return("application/json")
        allow(curl).to receive(:get).and_return(curl_response)
        req = GetItemIdRequest.new(client, 'hosters', 'linode')
        resp = Response.new(req.run)
        expect(GetItemIdRequest.item_id(resp)).to eq(25)
      end
    end

    describe 'SigninRequest' do
      it 'url is /users/signin' do
        curl = double('curl')
        client = HttpClient.new(curl, 'http', 'localhost')
        expect(curl).to receive(:post).with('http://localhost/users/sign_in',
                                           "user%5Bemail%5D=foo%40bar.com&user%5Bpassword%5D=foobar&authenticity_token=xyz",
                                           "application/x-www-form-urlencoded").once

        req = SigninRequest.new(client, 'foo@bar.com', 'foobar', 'xyz')
        req.run
      end
    end
  end
end
