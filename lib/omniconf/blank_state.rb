module Omniconf
  class BlankSlate
    # do not undef these methods
    WHITELIST = %w(inspect object_id)

    instance_methods.map(&:to_s).each do |method|
      undef_method method unless method.start_with?('__') || WHITELIST.include?(method)
    end
  end
end

