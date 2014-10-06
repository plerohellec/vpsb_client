module VpsbClient
  module Api
    class GetCurrentTrialRequest < GetRequest
      def initialize(http_client, params)
        super(http_client)
        @application_id = params[:application_id]
        @plan_id = params[:plan_id]
        @hoster_id = params[:hoster_id]
      end

      def url_path
        "/admin/trials/current"
      end

      def query_params
        { hoster_id: @hoster_id,
          application_id: @application_id,
          plan_id: @plan_id
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