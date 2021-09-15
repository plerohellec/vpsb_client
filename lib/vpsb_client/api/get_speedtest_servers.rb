module VpsbClient
  module Api
    class GetSpeedtestServers < GetRequest
      def initialize(http_client)
        super(http_client)
      end

      def url_path
        "/api/speedtest_servers"
      end

      def self.servers_by_region(http_response)
        return [] if http_response.parsed_response.empty?
        servers_by_region = http_response.parsed_response
      end

      def self.servers(http_response)
        return [] if http_response.parsed_response.empty?
        servers_by_region = http_response.parsed_response
        servers = []
        servers_by_region.each do |region, a|
          a.each do |server|
            servers << server['host']
          end
        end
        servers.uniq
      end
    end
  end
end

