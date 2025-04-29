module DashX
  class ConfigurationError < StandardError; end

  class Config
    attr_accessor :base_uri
    attr_accessor :public_key
    attr_accessor :private_key
    attr_accessor :target_environment

    def validate!
      raise ConfigurationError, 'public_key must be set' if public_key.nil? || public_key.empty?
      raise ConfigurationError, 'private_key must be set' if private_key.nil? || private_key.empty?
      raise ConfigurationError, 'target_environment must be set' if target_environment.nil? || target_environment.empty?
    end
  end
end
