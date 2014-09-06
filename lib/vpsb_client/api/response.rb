module VpsbClient
  module Api
    class Response
      attr_reader :code, :body_str, :content_type

      class NotAuthenticated < Exception; end
      class HttpError < Exception; end

      def initialize(curl_response)
        @code = curl_response.response_code
        raise NotAuthenticated, "code=#{@code}" if @code == 401
        raise HttpError, "code=#{@code}" unless success?

        @body_str = curl_response.body_str
        @content_type = curl_response.content_type
      end

      def parsed_response
        @parsed_response ||= JSON.decode(@body_str)
      end

      def success?
        [200, 302].include?(@code)
      end
    end
  end
end
