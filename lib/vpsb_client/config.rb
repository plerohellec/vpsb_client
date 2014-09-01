require 'yaml'

module VpsbClient
  class Config
    def initialize(path)
      raise ArgumentError, "Can't find #{path}" unless File.exist?(path)
      @yml = YAML.load_file(path)
    end

    def value(name)
      @yml.fetch(name)
    end

    def [](name)
      value(name)
    end
  end
end
