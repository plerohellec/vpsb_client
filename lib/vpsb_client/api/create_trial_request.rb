module VpsbClient
  module Api
    class CreateTrialRequest < PostRequest
      MANDATORY_PARAM_NAMES = [ :started_at, :hoster_id, :application_id, :plan_id, :os, :total_memory_mb, :free_memory_mb, :cpu_type, :num_cores, :kernel, :client_hostname, :ruby_version, :rails_version, :datacenter, :cpu_mhz, :root_disk_space_gb, :hyperthreaded, :cache_size_kb, :expected_tests]
      OPTIONAL_PARAM_NAMES = [ :provision_seconds, :postgresql_version, :vps_instance_id, :private ]

      def initialize(http_client, trial)
        super(http_client)
        @trial = trial
        MANDATORY_PARAM_NAMES.each do |name|
          raise ArgumentError, "param #{name} is mandatory" unless @trial.keys.include?(name)
        end
        @trial.keys.each do |name|
          if !MANDATORY_PARAM_NAMES.include?(name) && !OPTIONAL_PARAM_NAMES.include?(name)
            raise ArgumentError, "param #{name} is not allowed"
          end
        end
      end

      def url_path
        "/api/trials"
      end

      def post_params
        @post_params = { trial: @trial }
      end

      def content_type
        'application/json'
      end

      def self.trial(http_response)
        http_response.parsed_response
      end

      def self.trial_id(http_response)
        trial(http_response)['id']
      end
    end
  end
end
