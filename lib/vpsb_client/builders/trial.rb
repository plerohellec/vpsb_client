module VpsbClient
  module Builders
    class Trial
      def initialize(hoster_id, application_id, plan_id, comment)
        @hoster_id = hoster_id
        @application_id = application_id
        @plan_id = plan_id
        @comment = comment
      end

      def params
        post_params = {}

        trial_params = {}
        trial_params[:hoster_id] = @hoster_id
        trial_params[:application_id] = @application_id
        trial_params[:plan_id] = @plan_id

        trial_params[:comment] = @comment

        cpuinfo_parser = SystemInfoParser::CpuinfoParser.new
        cpuinfo_parser.parse
        trial_params[:cpu_type] = cpuinfo_parser.model
        trial_params[:num_cores] = cpuinfo_parser.num

        issue_parser = SystemInfoParser::IssueParser.new
        issue_parser.parse
        trial_params[:os] = issue_parser.os

        memory_parser = SystemInfoParser::MemoryParser.new
        memory_parser.parse
        trial_params[:free_memory_mb] = memory_parser.free

        post_params[:trial] = trial_params
        post_params
      end
    end
  end
end