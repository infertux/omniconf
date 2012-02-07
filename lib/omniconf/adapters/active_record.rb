require 'active_record'

module Omniconf
  module Adapter
    class ActiveRecord < Base
      def initialize id, params
        @source_id = id
        defaults = {
          :model_name => :ConfigValue
        }
        defaults.merge!({
          :environment => Rails.env,
          :config_file => File.join(Rails.root, 'config/database.yml')
        }) if defined? Rails
        @params = defaults.merge params
      end

      def load_configuration!
        setup

        # create an empty config in case ActiveRecord raises
        @configuration = Configuration.new self

        begin
          records = @model.all
        rescue ::ActiveRecord::StatementInvalid => e
          Omniconf.logger.warn "Could not load #{@params[:model_name]} model, ignoring this configuration source."
          return
        end

        # build the configuration hash from DB (nesting on dots)
        hash = {}
        records.map do |record|
          key, value = record.key.split('.'), record.value
          el = key[0..-2].inject(hash) {|r,e| r[e] ||= {} }
          raise unless el[key.last].nil?
          el[key.last] = value
        end
        @configuration = Configuration.new self, hash

        Omniconf.merge_configuration! @source_id
      end

      def set_value(key, value)
        key = key.join('.')
        if item = @model.find_by_key(key)
          item.value = value
        else
          item = @model.new(:key => key, :value => value)
        end
        item.save!
        item.value
      end

      def setup
        # define the ActiveRecord model if missing
        unless Object.const_defined? @params[:model_name]
          unless ::ActiveRecord::Base.connected?
            ::ActiveRecord::Base.configurations = YAML::load(IO.read(@params[:config_file]))
            ::ActiveRecord::Base.establish_connection(@params[:environment])
          end

          klass = Class.new ::ActiveRecord::Base do
            validates_uniqueness_of :key
          end

          Object.const_set @params[:model_name], klass
        end

        @model ||= @params[:model_name].to_s.constantize
      end
    end
  end
end

