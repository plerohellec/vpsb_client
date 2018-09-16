module VpsbClient
  class HttpClient
    def initialize(curl_wrapper, protocol, hostname)
      @protocol = protocol
      @hostname = hostname
      @curl_wrapper = curl_wrapper
    end

    def get(request)
      @curl_wrapper.get(url(request), request.query_params)
    end

    def post(request)
      post_params = post_params(request, request.content_type)
      @curl_wrapper.post(url(request), post_params, request.content_type)
    end

    def put(request)
      put_params = put_params(request, request.content_type)
      @curl_wrapper.put(url(request), put_params, request.content_type)
    end

    private

    def url(request)
      "#{@protocol}://#{@hostname}#{request.url_path}"
    end

    def query_sep(query_string)
      query_string.empty? ? '' : '?'
    end

    def suffix(request)
      '.json' if request.accept == 'application/json'
    end

    def post_params(request, content_type)
      post_params = request.post_params
      if request.content_type == 'application/json'
        JSON.generate(post_params) # curl doesn't do the json encoding by itself
      else
        post_params # but curl does the www form encoding
      end
    end
    alias_method :put_params, :post_params

    def url_encode(params)
      return '' if params.empty?
      s = ''
      i = 0
      params.each do |k,v|
        s << '&' unless i==0
        s << "#{ERB::Util.url_encode(k)}=#{ERB::Util.url_encode(v)}"
        i += 1
      end
      s
    end
  end
end
