require 'yaml'

module VpsbClient
  class Config
    def initialize(path)
      raise ArgumentError, "Can't find #{path}" unless File.exist?(path)
      @yml = YAML.load_file(path)
    end

    def fetch(name, default=nil)
      default ? @yml.fetch(name, default) : @yml.fetch(name)
    end

    def [](name)
      fetch(name)
    end
  end
end
