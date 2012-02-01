# Mock Rails.{env,root} to test defaults settings
unless defined? Rails
  class Rails
    class << self
      def env
        'test'
      end

      def root
        File.join(File.dirname(__FILE__), '..')
      end
    end
  end
end

