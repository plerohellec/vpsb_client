class Manager
  attr_reader :client

  def initialize(client)
  end

  def get_current_trial
  end

  def create_trial
  end

  def last_uploaded_metric_end_date
  end

  def run

  end
end

class Config
  attr_reader :application_name, :hoster_name, :plan_name

  def initialize(path)
    raise ArgumentError, "Can't find #{path}" unless File.exist?(path)
    @yml = YAML.load_file(path)
  end

  def value(name)
    @yam.fetch(name)
  end
end

class AuthenticatedClient
  attr_reader :host

  def inialize(config_file_path)
  end

  def get_current_trial(date, app_name, hoster_name, plan_name)
  end

  def create_trial(start_date, app_name, hoster_name, plan_name)
  end

  def get_last_upload_date(trial_id)
  end

  def post_metric_interval(start_date, length, post_data)
  end
end

module Request

  class Request
    def initialize(config, http_client)
    end

    def run
      case method
      when :get
      then http_client.get(url, query_params)
          when :post
      then http_client.post(url, query_params, post_params)
      end
    end
  end

  class GetRequest < Request
    def method
      :get
    end
  end

  class PostRequest
    def method
      :post
    end
  end

  class GetCurrentTrial < GetRequest
    def initialize(config, http_client, application_id, plan_id, hoster_id)
    end

    def url
      "https://#{@host}/api/trials/current"
    end

    def query_params
      { hoster_id: @hoster_id,
        application_id: @application_id,
        plan_id: @plan_id
      }
    end
  end
end


class DataCollector
  def cpuinfo
  end

  def freemem
  end


end


