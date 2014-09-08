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
        trial_params = {}
        trial_params[:hoster_id] = @hoster_id
        trial_params[:application_id] = @application_id
        trial_params[:plan_id] = @plan_id

        trial_params[:comment] = @comment

        cpuinfo_parser = Builders::CpuinfoParser.new
        cpuinfo_parser.parse
        trial_params[:cpu_type] = cpuinfo_parser.model
        trial_params[:num_cores] = cpuinfo_parser.num

        issue_parser = Builders::IssueParser.new
        issue_parser.parse
        trial_params[:os] = issue_parser.os

        memory_parser = Builders::MemoryParser.new
        memory_parser.parse
        trial_params[:free_memory_mb] = memory_parser.free

        uname_parser = Builders::UnameParser.new
        uname_parser.parse
        trial_params[:kernel] = uname_parser.kernel

        trial_params
      end
    end
  end
end