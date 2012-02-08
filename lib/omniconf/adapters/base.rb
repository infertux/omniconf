require 'omniconf/configuration'

module Omniconf
  module Adapter
    class Base
      attr_reader :source_id
      attr_reader :configuration
      def reload_configuration!; load_configuration! end
    end
  end
end

