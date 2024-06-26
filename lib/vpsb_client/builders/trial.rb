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

        trial_params[:vps_instance_id] = @config.fetch_optional('vps_instance_id')

        cpuinfo_parser = Builders::CpuinfoParser.new
        begin
          cpuinfo_parser.parse
        rescue Builders::SystemInfoParser::NoMatchError => e
          cpuinfo_parser = Builders::LscpuinfoParser.new
          cpuinfo_parser.parse
        end
        trial_params[:cpu_type] = cpuinfo_parser.model
        trial_params[:num_cores] = cpuinfo_parser.num
        trial_params[:cpu_mhz] = cpuinfo_parser.mhz
        trial_params[:hyperthreaded] = cpuinfo_parser.hyperthreaded
        trial_params[:cache_size_kb] = cpuinfo_parser.cache_size_kb

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

        postgresql_version_parser = Builders::PostgresqlVersionParser.new
        postgresql_version_parser.parse
        trial_params[:postgresql_version] = postgresql_version_parser.version

        trial_params[:private] = @config.fetch_optional('private')

        trial_params[:expected_tests] = @config.fetch('expected_tests')

        trial_params
      end
    end
  end
end
