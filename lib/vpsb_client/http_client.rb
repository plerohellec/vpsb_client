require 'curb'

module VpsbClient
  class HttpClient
    def initialize(protocol, hostname, cookie_jar_path)
      @protocol = protocol
      @hostname = hostname
      @cookie_jar_path = cookie_jar_path
    end

    def get(request)
      resp = get_with_cookie_jar(request)
    end

    def post(request, csrf_token = nil)
      resp = post_with_cookie_jar(request, csrf_token)
    end

    private

    def url(request)
      query_string = encode(request.query_params)
      "#{@protocol}://#{@hostname}#{request.url_path}#{suffix(request)}#{query_sep(query_string)}#{query_string}"
    end

    def query_sep(query_string)
      query_string.empty? ? '' : '?'
    end

    def suffix(request)
      '.json' if request.accept == 'application/json'
    end

    def post_params(request, csrf_token = nil)
      post_params = request.post_params
      post_params[:authenticity_token] = csrf_token if csrf_token
      if request.content_type == 'application/json'
        JSON.encode(post_params)
      else
        encode(post_params)
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

    def encode(params)
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
