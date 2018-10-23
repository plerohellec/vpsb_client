require 'yaml'

module VpsbClient
  class Config
    def initialize(path)
      raise ArgumentError, "Can't find #{path}" unless File.exist?(path)
      @yml = YAML.load_file(path)
    end

    def fetch(name, default=nil)
      default ? @yml.fetch(name.to_s, default) : @yml.fetch(name.to_s)
    end

    def fetch_optional(name)
      return nil unless @yml.key?(name)
      @yml.fetch(name)
    end

    def [](name)
      fetch(name.to_s)
    end
  end
end
