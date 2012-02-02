require 'logger'
require "omniconf/version"
require "omniconf/settings"

module Omniconf
  class << self
    attr_reader :settings # Omniconf settings
    attr_accessor :configuration # Global configuration as a RecursiveOpenStruct
    attr_writer :configuration_hash # Global configuration as an Hash

    def configuration_hash
      @configuration_hash ||= {}
    end

    def logger
      unless @logger
        # @logger ||= defined? Rails.logger ? Rails.logger : Logger.new(STDOUT)
        @logger = Logger.new(STDOUT)
        @logger.level = @settings.logger_level if @settings
        @logger.level = Logger::INFO if @logger.level.nil?
      end
      @logger
    end

    def setup
      @settings = Settings.new
      yield @settings

      register_sources

      @settings.load_configuration = true if @settings.load_configuration.nil?
      load_configuration! if @settings.load_configuration
    end

    def load_configuration!
      @settings.sources.each do |source_id, params|
        params[:adapter].load_configuration!
        Omniconf.logger.info "Loaded configuration from #{source_id} source"
      end
    end

    private

    def register_sources
      @settings.sources.each do |source_id, params|
        adapter_file = params[:type].to_s
        require "omniconf/adapters/base"
        require "omniconf/adapters/#{adapter_file}"
        adapter_class = adapter_file.to_s.split('_').map {|w| w.capitalize}.join
        raise unless params[:adapter].nil?
        params[:adapter] = Omniconf::Adapter.class_eval do
          const_get(adapter_class).new(params)
        end
        Omniconf.logger.debug "Registered #{adapter_class}::#{source_id} source"
      end
    end

  end
end

