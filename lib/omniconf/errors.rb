module Omniconf
  # Raised when trying to get or set a non-existent configuration value
  class UnknownConfigurationValue < StandardError; end

  # Raised when trying to set a read-only configuration value
  class ReadOnlyConfigurationValue < StandardError; end
end
