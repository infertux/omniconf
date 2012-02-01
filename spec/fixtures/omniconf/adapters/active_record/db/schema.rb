ActiveRecord::Schema.define :version => 0 do
  create_table :config_values, :force => true do |t|
    t.string :key
    t.string :value
  end
end

ConfigValue.create!({:key => 'foo', :value => 'bar'})
ConfigValue.create!({:key => 'foo2', :value => 'bar2'})

