class BlankSlate
  instance_methods.each do |method|
    undef_method method unless method =~ /^__/ or
      [:inspect, :instance_of?, :object_id, :should].include? method.to_sym
  end
end

