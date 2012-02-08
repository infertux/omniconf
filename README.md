# Omniconf [![Build Status](https://secure.travis-ci.org/Picklive/omniconf.png)](http://travis-ci.org/#!/Picklive/omniconf)

A _RubyGem_ that provides an application-agnostic configuration merger.

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

## Getting values

```ruby
$ rails c
> Omniconf.configuration.some_config_from_database # value from ConfigValue model
 => "abc"
> Omniconf.configuration.some_config_from_yaml # value from config/settings.yml
 => 123
> Omniconf.configuration.api.username # it works with nested values too
 => "root"
> Omniconf.configuration.api # outputs a hash if nested
 => {"username"=>"root"}
> Omniconf.configuration.non_existant.config_value # raises an exception
 => Omniconf::UnknownConfigurationValue: cannot get a configuration value with no parent
```

## Setting values

```ruby
> Omniconf.configuration.some_config_from_database = "def" # updates value in DB using ConfigValue model
 => "def"
> Omniconf.configuration.some_config_from_yaml = 456 # raises an exception because the value comes from YAML - who would want to update a YAML file?!
 => Omniconf::ReadOnlyConfigurationValue: cannot set 'some_config_from_yaml' because it belongs to a read-only back-end source (id: :yaml_config, type: Yaml)
> Omniconf.configuration.api.username = "admin" # it works with nested values too
 => "admin"
> Omniconf.configuration.brand_new_value = "whatever" # raises an exception because you've got to tell which back-end will store the new value
 => Omniconf::UnknownConfigurationValue: cannot set a configuration value with no parent
> Omniconf.sources[:database_config].brand_new_value = "whatever" # adds a new row in ConfigValue model
 => "whatever"
```

## Back-end sources

`:type` is the only required parameter.
Other parameters default to standard values for Rails.

### Yaml

Nothing to configure apart from having a YAML file.

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

## Reserved words

/!\ You should not use these names as configuration keys:

- `to_hash`: it's a helper which returns the configuration as a hash
- `inspect`: outputs sub-values as a hash
- `get_or_default`: it's a helper which returns the value if it exists or creates it otherwise (usage: `get_or_default(key, default_value)`)
- `method_missing`: used internally
- everything which starts with `__` (double underscore): used internally

# Testing

`rake`

Tested against _ree_, _ruby-1.9.2_ and _ruby-1.9.3_.

# License

MIT

