require 'json'
require 'erb'
require 'io/console'

require 'url_builder'

module VpsbClient
  class AuthenticatedClient
    def initialize(user, url_builder)
      @user = user
      @password = nil
      @auth_tokens = {}
      @url_builder = url_builder
    end

    def get(url)
      http = CurlWithCookieJar.get(url)
      puts "#{http.response_code} GET #{url}"
      http
    end

    def post(url, post_json, post_params)
      http = CurlWithCookieJar.post(url, post_json, post_params)
      puts "#{http.response_code} POST #{url}"
      http
    end

    def logged_in?
      http = CurlWithCookieJar.get(@url_builder.new_trial_url)
      puts "logged_in? http.response_code=#{http.response_code} status=#{http.status}"
      success_response_code?(http.response_code) && http.response_code != 302
    end

    def sign_in
      puts "Enter password: "
      password = STDIN.noecho(&:gets).chomp
#       http = CurlWithCookieJar.post(@url_builder.sign_in_url,
#                                     { 'authenticity_token' => authenticity_token(@url_builder.sign_in_url),
#                                       'user[email]' => @user,
#                                       'user[password]' => password })
      params = prepared_post_params({ 'user[email]' => @user,'user[password]' => password }, @url_builder.sign_in_url, false)
      http = post(@url_builder.sign_in_url,
                  false,
                  params)
      puts "sign_in http.response_code=#{http.response_code}"
      http
    end

    def get_current_trial
    end

    def create_trial(post_params)
      post(@url_builder.create_trial_url, true, prepared_post_params(post_params, @url_builder.new_trial_url))
    end

    def create_metric(post_params)
      post(@url_builder.create_metric_url, true, prepared_post_params(post_params, @url_builder.new_metric_url))
    end

    def authenticity_token(form_url)
      return @auth_tokens[form_url] if @auth_tokens[form_url]
      regex = /<meta content=\"(?<token>[^\"]+)" name="csrf-token" \/>/
      http = get(form_url)
      raise http.status unless success_response_code?(http.response_code)
      @auth_tokens[form_url] = http.body_str.match(regex) do |match_data|
        match_data[:token]
      end
    end

    private

    def success_response_code?(code)
      code >=200 && code<300 || code==302
    end

    def prepared_post_params(post_params, form_url, json = true)
      params = post_params.merge('authenticity_token' => authenticity_token(form_url))
      params = params.to_json if json
      params
    end
  end

  class CurlWithCookieJar
    COOKIE_JAR_PATH = '/tmp/cookie_jar'

    def self.get(url)
      Curl.get(url) do |curl|
        curl.ssl_verify_host = false
        curl.ssl_verify_peer = false
        curl.enable_cookies = true
        curl.cookiejar = COOKIE_JAR_PATH
        curl.cookiefile = COOKIE_JAR_PATH

        yield curl if block_given?
      end
    end

    def self.post(url, post_json = false, post_params = {}, &block)
      Curl.post(url, post_params) do |curl|
        curl.ssl_verify_host = false
        curl.ssl_verify_peer = false
        curl.enable_cookies = true
        curl.cookiejar = COOKIE_JAR_PATH
        curl.cookiefile = COOKIE_JAR_PATH
        curl.headers['content-type'] = 'application/json' if post_json

        yield curl if block_given?
      end
    end
  end
end

