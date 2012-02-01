require 'recursive_open_struct'

module Omniconf
  module Adapter
    class Base
      attr_accessor :configuration_hash

      def configuration
        RecursiveOpenStruct.new @configuration_hash
      end

      def merge_configuration! with_config
        Omniconf.logger.debug "Merged global configuration BEFORE: #{Omniconf.configuration_hash.inspect}"
        adapter = self.class.ancestors.first.to_s.split(':').last
        Omniconf.logger.debug "Merging from #{adapter} configuration: #{with_config.inspect}"
        Omniconf.configuration_hash.merge!(with_config) do |key, old_val, new_val|
          Omniconf.logger.warn \
            "'#{key}' has been overriden with value from #{adapter} configuration " <<
            "(old value: #{old_val.inspect}, new value: #{new_val.inspect})" if new_val != old_val
          new_val
        end
        Omniconf.logger.debug "Merged global configuration AFTER: #{Omniconf.configuration_hash.inspect}"
        Omniconf.configuration = RecursiveOpenStruct.new Omniconf.configuration_hash
      end
    end
  end
end

