*THIS STUFF IS STILL ALPHA!*

# Setup

Configure and load desired backends by creating a new initializer `config/initializers/omniconf.rb`:

```ruby
Omniconf.setup do |config|
  config.sources = {
    :yaml_config => {
      :type => :yaml,
      :file => "config/settings.yml"
    },
    :database_config => {
      :type => :active_record,
      :model_name => :ConfigValue
    }
  }
end
```

# Usage

```ruby
$ rails c
> Omniconf.configuration.some_config_from_database # value from ConfigValue model
"abc"
> Omniconf.configuration_hash["some_config_from_database"] # if you prefer the hash way
"abc"
> Omniconf.configuration.some_config_from_yaml # value from config/settings.yml
123
> Omniconf.configuration.api.username # it works with nested values too
"root"
```

## Backend sources

`:type` is the only required parameter.
Other parameters default to standard values for Rails.

### Yaml

Nothing to configure apart from a YAML file.

_Note: read-only._

### ActiveRecord

Add `gem 'activerecord'` in your `Gemfile`.

Create a new migration to add the config table: _(FIXME: add a rake task for this)_

```ruby
class CreateConfigValues < ActiveRecord::Migration
  def change
    create_table :config_values do |t|
      t.string :key, :null => false
      t.string :value, :null => false
    end
    add_index :config_values, :key, :unique => true
  end
end
```

### Redis

Add `gem 'redis'` in your `Gemfile`.

Not yet implemented.

# Testing

`rake`

Tested on _ree-1.8.7_ and _ruby-1.9.3_.

