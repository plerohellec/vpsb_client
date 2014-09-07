module VpsbClient
  module Api
    class CreateTrialRequest < PostRequest
      MANDATORY_PARAM_NAMES = [ :hoster_id, :application_id, :plan_id, :comment, :os, :free_memory_mb, :cpu_type, :num_cores]

      def initialize(http_client, params)
        super(http_client)
        MANDATORY_PARAM_NAMES.each do |name|
          raise ArgumentError, "param #{name} is mandatory" unless params.keys.include?(name)
        end
        params.key.each do |name|
          raise ArgumentError, "param #{name} is not allowed" unless MANDATORY_PARAM_NAMES.include?(name)
        end
      end

      def url_path
        "/admin/trial"
      end
    end
  end
end
