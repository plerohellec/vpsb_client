module VpsbClient
  class Config
    attr_reader :application_name, :hoster_name, :plan_name

    def initialize(path)
      raise ArgumentError, "Can't find #{path}" unless File.exist?(path)
      @yml = YAML.load_file(path)
    end

    def value(name)
      @yam.fetch(name)
    end
  end
end
