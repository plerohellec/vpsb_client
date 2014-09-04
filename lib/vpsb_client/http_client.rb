module VpsbClient
  class HttpClient
    def initialize(protocol, hostname, cookie_jar_path)
      @protocol = protocol
      @hostname = hostname
      @cookie_jar_path = cookie_jar_path
    end

    def get(request)
      resp = get_with_cookie_jar(request)
      HttpResponse.new(resp)
    end

    def post(request, csrf_token)
      resp = post_with_cookie_jar(request, csrf_token)
      HttpResponse.new(resp)
    end

    private

    def url(request)
      "#{@protocol}://#{@hostname}#{request.url_path}/#{request.query_params.to_query}"
    end

    def post_params(request, csrf_token)
      post_params = request.post_params
      post_params[:authenticity_token] = csrf_token
      if request.content_type = 'application/json'
        JSON.encode(post_params)
      else
        post_params.to_query
      end
    end

    def get_with_cookie_jar(request, &block)
      Curl.get(url(request)) do |curl|
        curl.ssl_verify_host = false
        curl.ssl_verify_peer = false
        curl.enable_cookies = true
        curl.cookiejar = @cookie_jar_path
        curl.cookiefile = @cookie_jar_path

        yield curl if block_given?
      end
    end

    def post_with_cookie_jar(request, csrf_token, &block)
      Curl.post(url(request), post_params(request, csrf_token)) do |curl|
        curl.ssl_verify_host = false
        curl.ssl_verify_peer = false
        curl.enable_cookies = true
        curl.cookiejar = @cookie_jar_path
        curl.cookiefile = @cookie_jar_path
        curl.headers['content-type'] = request.content_type

        yield curl if block_given?
      end
    end
  end
end
