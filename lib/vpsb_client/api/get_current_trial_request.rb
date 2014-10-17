module VpsbClient
  module Api
    class GetCurrentTrialRequest < GetRequest
      def initialize(http_client, params)
        super(http_client)
        @client_hostname = params.fetch(:client_hostname)
      end

      def url_path
        "/admin/trials/current"
      end

      def query_params
        {
          client_hostname: @client_hostname
        }
      end

      def self.trial(http_response)
        return nil if http_response.parsed_response.empty?
        http_response.parsed_response.first
      end

      def self.trial_id(http_response)
        t = trial(http_response)
        t ? t['id'] : nil
      end
    end
  end
end