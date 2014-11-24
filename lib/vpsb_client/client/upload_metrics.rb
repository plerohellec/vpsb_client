module VpsbClient
  module Client
    module UploadMetrics
      def upload_metrics(trial)
        unless enabled?
          logger.debug "not running because vpsb_client is disabled"
          return
        end

        prepare_logfiles

        metric_ids = []
        [ 10*60, 3600, 86400 ].each do |interval_length|
          upload_for_interval_Length(trial, interval_length)
        end
        metric_ids
      end

      private

      def upload_for_interval_Length(trial, interval_length)
        last_started_at = trial_last_metric_started_at(trial['id'], interval_length)
        if last_started_at
          start_time = last_started_at + interval_length
          force = true
        else
          trial_started_at = DateTime.parse(trial['started_at']).to_time
          start_time = trial_started_at
          force = false
        end
        logger.debug "[vpsb] upload_metrics: length=#{interval_length} start_time=#{start_time} force=#{force}"
        interval_config = Metrics::IntervalConfig.new(start_time, interval_length, force: force)
        metrics_manager = metrics_manager(trial['id'], interval_config)
        metrics_manager.run
        metric_ids += metrics_manager.created_metric_ids
      end
    end
  end
end
