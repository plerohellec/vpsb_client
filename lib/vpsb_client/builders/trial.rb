module VpsbClient
  module Builders
    class Trial
      def initialize(config, hoster_id=nil, application_id=nil, plan_id=nil)
        @config = config
        @hoster_id = hoster_id
        @application_id = application_id
        @plan_id = plan_id
      end

      def lookup_params
        trial_params = {}
        trial_params[:client_hostname] = @config['client_hostname']
        trial_params
      end

      def create_params
        trial_params = {}
        trial_params[:started_at] = Time.now
        trial_params[:hoster_id] = @hoster_id if @hoster_id
        trial_params[:application_id] = @application_id if @application_id
        trial_params[:plan_id] = @plan_id if @plan_id

        trial_params[:comment] = @config.fetch_optional('comment')

        cpuinfo_parser = Builders::CpuinfoParser.new
        cpuinfo_parser.parse
        trial_params[:cpu_type] = cpuinfo_parser.model
        trial_params[:num_cores] = cpuinfo_parser.num
        trial_params[:cpu_mhz] = cpuinfo_parser.mhz

        issue_parser = Builders::IssueParser.new
        issue_parser.parse
        trial_params[:os] = issue_parser.os

        memory_parser = Builders::MemoryParser.new
        memory_parser.parse
        trial_params[:total_memory_mb] = memory_parser.total
        trial_params[:free_memory_mb] = memory_parser.free

        uname_parser = Builders::UnameParser.new
        uname_parser.parse
        trial_params[:kernel] = uname_parser.kernel

        df_parser = Builders::DfParser.new
        df_parser.parse
        trial_params[:root_disk_space_gb] = df_parser.root_disk_space_gb

        trial_params[:client_hostname] = @config['client_hostname']
        trial_params[:ruby_version] = RUBY_VERSION
        trial_params[:rails_version] = defined?(Rails) ? Rails.version : nil

        trial_params[:datacenter] = @config['datacenter']

        trial_params[:provision_seconds] = @config.fetch_optional('provision_seconds')
        trial_params[:postgresql_version] = @config.fetch_optional('postgresql_version')

        trial_params
      end
    end
  end
end
