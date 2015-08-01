require 'curb'

module VpsbClient
  class CurlWrapper
    def initialize(auth_token)
      @auth_token = auth_token
    end

    def get(url, &block)
      Curl.get(url) do |curl|
        curl.ssl_verify_host = false
        curl.ssl_verify_peer = false
        curl.headers['Authorization'] = "Token #{@auth_token}"

        yield curl if block_given?
      end
    end

    def post(url, post_params, content_type, &block)
      Curl.post(url, post_params) do |curl|
        curl.ssl_verify_host = false
        curl.ssl_verify_peer = false
        curl.headers['content-type'] = content_type
        curl.headers['Authorization'] = "Token #{@auth_token}"

        yield curl if block_given?
      end
    end

    def put(url, put_params, content_type, &block)
      Curl.put(url, put_params) do |curl|
        curl.ssl_verify_host = false
        curl.ssl_verify_peer = false
        curl.headers['content-type'] = content_type
        curl.headers['Authorization'] = "Token #{@auth_token}"

        yield curl if block_given?
      end
    end
  end
end
