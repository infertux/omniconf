module Omniconf
  module Adapter
    module ReadOnly
      def set_value(key, value)
        raise ReadOnlyConfigurationValue, "cannot set '#{key.join('.')}' " <<
          "because it belongs to a read-only back-end source " <<
          "(id: #{@source_id.inspect}, type: #{self.class.to_s.demodulize})"
      end
    end
  end
end

