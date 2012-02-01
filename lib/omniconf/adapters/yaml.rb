module Omniconf
  module Adapter
    class Yaml < Base

      def initialize params
        defaults = {
          :environment => Rails.env,
          :file => File.join(Rails.root, 'config/settings.yml')
        }
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

