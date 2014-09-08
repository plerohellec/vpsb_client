module VpsbClient
  module Api
    class CreateTrialRequest < PostRequest
      MANDATORY_PARAM_NAMES = [ :hoster_id, :application_id, :plan_id, :comment, :os, :free_memory_mb, :cpu_type, :num_cores, :kernel]

      def initialize(http_client, params, csrf_token)
        super(http_client, csrf_token)
        @post_params = { trial: params }
        MANDATORY_PARAM_NAMES.each do |name|
          raise ArgumentError, "param #{name} is mandatory" unless params.keys.include?(name)
        end
        params.keys.each do |name|
          raise ArgumentError, "param #{name} is not allowed" unless MANDATORY_PARAM_NAMES.include?(name)
        end
      end

      def url_path
        "/admin/trials"
      end

      def post_params
        @post_params
      end

      def content_type
        'application/json'
      end

      def self.trial_id(http_response)
        http_response.parsed_response['id']
      end
    end
  end
end
