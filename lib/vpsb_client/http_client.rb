module VpsbClient
  class HttpClient
    def initialize(curl_wrapper, protocol, hostname)
      @protocol = protocol
      @hostname = hostname
      @curl_wrapper = curl_wrapper
    end

    def get(request)
      @curl_wrapper.get(url(request))
    end

    def post(request, csrf_token = nil)
      post_params = post_params(request, csrf_token, request.content_type)
      @curl_wrapper.post(url(request), post_params, request.content_type)
    end

    private

    def url(request)
      query_string = url_encode(request.query_params)
      "#{@protocol}://#{@hostname}#{request.url_path}#{suffix(request)}#{query_sep(query_string)}#{query_string}"
    end

    def query_sep(query_string)
      query_string.empty? ? '' : '?'
    end

    def suffix(request)
      '.json' if request.accept == 'application/json'
    end

    def post_params(request, csrf_token, content_type)
      post_params = request.post_params
      post_params[:authenticity_token] = csrf_token if csrf_token
      if request.content_type == 'application/json'
        JSON.generate(post_params) # curl doesn't do the json encoding by itself
      else
        post_params # but curl does the www form encoding
      end
    end

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
