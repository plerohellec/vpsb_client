require 'curb'

module VpsbClient
  class CurlWrapper
    def initialize(cookie_jar_path)
      @cookie_jar_path = cookie_jar_path
    end

    def get(url, &block)
      Curl.get(url) do |curl|
        curl.ssl_verify_host = false
        curl.ssl_verify_peer = false
        curl.enable_cookies = true
        curl.cookiejar = @cookie_jar_path
        curl.cookiefile = @cookie_jar_path

        yield curl if block_given?
      end
    end

    def post(url, post_params, content_type, &block)
      Curl.post(url, post_params) do |curl|
        curl.ssl_verify_host = false
        curl.ssl_verify_peer = false
        curl.enable_cookies = true
        curl.cookiejar = @cookie_jar_path
        curl.cookiefile = @cookie_jar_path
        curl.headers['content-type'] = content_type

        yield curl if block_given?
      end
    end
  end
end
