module VpsbClient
  module Api
    class UpdatePlanGrades < PutRequest
      def url_path
        "/api/plans/update_plan_grades"
      end

      def accept
        nil
      end
    end
  end
end
