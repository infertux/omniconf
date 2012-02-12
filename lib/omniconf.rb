require 'logger'
require 'omniconf/version'
require 'omniconf/helpers'
require 'omniconf/errors'
require 'omniconf/settings'
require 'omniconf/adapters/base'

module Omniconf
  class << self
    attr_reader :settings # Omniconf settings
    attr_reader :configuration # global merged configuration
    alias_method :conf, :configuration # shortcut for the lazy people

    def setup
      @settings ||= Settings.new
      yield @settings

      register_sources

      @settings.load_configuration = true if @settings.load_configuration.nil?
      load_configuration! if @settings.load_configuration
    end

    def logger
      return @logger ||= Rails.logger if defined? Rails

      @logger ||= Logger.new(STDOUT)
      @logger.level = @settings.logger_level || Logger::INFO
      @logger
    end

    # Returns a mapping on source adapters
    def sources
      @settings.sources.to_a.inject({}) do |result, (source_id, source)|
        result[source_id] = source[:adapter].configuration
        result
      end
    end

    def load_configuration!
      @configuration = Omniconf::Configuration.new self
      @settings.sources.each do |source_id, params|
        params[:adapter].load_configuration!
        Omniconf.logger.info "Loaded configuration from #{source_id.inspect} source"
      end
    end

    alias_method :reload_configuration!, :load_configuration!

    def merge_configuration! source_id
      Omniconf.logger.debug "Merging from #{source_id.inspect} source"
      source_config = Omniconf.sources[source_id].to_hash
      global_config = Omniconf.configuration.to_hash
      global_config.recursive_merge!(source_config) do |key, old_val, new_val|
        Omniconf.logger.warn \
          "'#{key}' has been overriden with value from #{source_id.inspect} source " <<
          "(old value: #{old_val.inspect}, new value: #{new_val.inspect})"
      end
    end

    def set_value(key, value)
      found = false
      @settings.sources.to_a.reverse.each do |source_id, source|
        # We try to find the original source overriding the last merged one,
        # hence we scan sources backwards
        adapter = source[:adapter]
        config = adapter.configuration.to_hash
        element = key[0..-2].inject(config) { |result, el| result[el] }
        if element and element[key.last] # we've found it in the current source
          element[key.last] = value
          adapter.set_value(key, value)
          found = true
          break
        end
      end
      raise UnknownConfigurationValue,
            "cannot set a configuration value with no parent" unless found
    end

    private
    def register_sources
      return unless @settings.sources
      @settings.sources.each do |source_id, params|
        adapter_file = params[:type].to_s
        require "omniconf/adapters/#{adapter_file}"
        adapter_class = adapter_file.split('_').map {|w| w.capitalize}.join
        raise unless params[:adapter].nil?
        params[:adapter] = Omniconf::Adapter.class_eval do
          const_get(adapter_class).new(source_id, params)
        end
        Omniconf.logger.debug "Registered #{adapter_class}::#{source_id} source"
      end
    end
  end
end

