require 'active_record'

module Omniconf
  module Adapter
    class ActiveRecord < Base
      attr_reader :model

      def initialize params
        defaults = {
          :model_name => :ConfigValue,
          :environment => Rails.env,
          :config_file => File.join(Rails.root, 'config/database.yml')
        }
        @params = defaults.merge params
      end

      def load_configuration!
        setup
        @configuration_hash = {}

        begin
          records = @model.all
        rescue ::ActiveRecord::StatementInvalid => e
          Omniconf.logger.warn "Could not load #{@params[:model_name]} model, ignoring this configuration source."
          return
        end

        records.map do |record|
          @configuration_hash[record.key] = record.value
        end
        merge_configuration! @configuration_hash
      end

      def setup
        unless Object.const_defined? @params[:model_name]
          unless ::ActiveRecord::Base.connected?
            ::ActiveRecord::Base.configurations = YAML::load(IO.read(@params[:config_file]))
            ::ActiveRecord::Base.establish_connection(@params[:environment])
          end

          klass = Class.new ::ActiveRecord::Base do
            validates_uniqueness_of :key

            def self.[]=(key, value)
              if item = self.find_by_key(key.to_s)
                item.value = value.to_s
              else
                item = self.new(:key => key.to_s, :value => value.to_s)
              end
              item.save!
              item.value
            end

            def self.[](key)
              if item = find_by_key(key.to_s)
                return item.value
              end
            end

            def self.get_or_default(key, default)
              if item = find_by_key(key.to_s)
                return item.value
              else
                self[key] = default
                return default
              end
            end

          end

          Object.const_set @params[:model_name], klass
        end

        @model ||= @params[:model_name].to_s.constantize
      end
    end
  end
end

