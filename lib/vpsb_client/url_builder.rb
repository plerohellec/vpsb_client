module VpsbClient
  class UrlBuilder
    def initialize(host)
      if host =~ /^http/
        @host = host
      else
        @host = "https://#{host}"
      end
    end

    def sign_in_url
      "#{@host}/users/sign_in"
    end

    def new_trial_url
      "#{@host}/admin/trials/new"
    end

    def create_trial_url
      "#{@host}/admin/trials.json"
    end

    def new_metric_url
      "#{@host}/admin/metrics/new"
    end

    def create_metric_url
      "#{@host}/admin/metrics.json"
    end

    def url_with_path(path, options={}, query_params={})
      url = "#{@host}/#{path}"
      url << '.json' if options.fetch(:json, false)
      append_query_params(url, query_params)
    end

    def append_query_params(url, query_params)
      return url if query_params.empty?
      url << '?'
      i = 0
      query_params.each do |k,v|
        url << '&' unless i==0
        url << "#{ERB::Util.url_encode(k)}=#{ERB::Util.url_encode(v)}"
        i += 1
      end
      url
    end
  end
end

