require 'omniconf/adapters/read_only'

module Omniconf
  module Adapter
    class Yaml < Base
      include ReadOnly

      def initialize id, params
        @source_id = id
        defaults = {}
        defaults.merge!({
          :environment => Rails.env,
          :file => File.join(Rails.root, 'config/settings.yml')
        }) if defined? Rails
        @params = defaults.merge params
      end

      def load_configuration!
        yaml = ::YAML.load_file(@params[:file])[@params[:environment]]
        @configuration = Omniconf::Configuration.new(self, yaml)

        Omniconf.merge_configuration! @source_id
      end
    end
  end
end

