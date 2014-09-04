module VpsbClient
  class HttpResponse
    attr_reader :code, :body_str, :content_type

    def initialize(curl_response)
      @code = curl_response.reposnse_code
      @body_str = curl_response.body_str
      @content_type = curl_response.content_type
    end

    def parsed_response
      @parsed_response ||= JSON.decode(@body_str)
    end

    def success?
      @code == 200
    end
  end
end
