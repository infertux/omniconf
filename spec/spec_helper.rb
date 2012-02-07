require 'omniconf'

Omniconf.setup do |config|
  config.load_configuration = false
  config.logger_level = Logger::ERROR # don't pollute specs output
end

