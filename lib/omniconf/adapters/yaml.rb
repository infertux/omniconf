module Omniconf
  module Adapter
    class Yaml < Base

      def initialize params
        defaults = {}
        defaults.merge!({
          :environment => Rails.env,
          :file => File.join(Rails.root, 'config/settings.yml')
        }) if defined? Rails
        @params = defaults.merge params
      end

      def load_configuration!
        yaml = ::YAML.load_file(@params[:file])
        @configuration_hash = yaml[@params[:environment]]
        merge_configuration! @configuration_hash
      end

    end
  end
end

