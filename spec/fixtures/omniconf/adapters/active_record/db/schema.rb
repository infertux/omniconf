ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define :version => 0 do
  create_table :config_values, :force => true do |t|
    t.string :key
    t.string :value
  end
end

ConfigValue.create!({:key => 'ar_key', :value => 'ar_value'})
ConfigValue.create!({:key => 'nested.ar_key', :value => 'nested_ar_value'})
ConfigValue.create!({:key => 'nested.overridden', :value => 'by_ar'})

