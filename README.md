# Omniconf [![Build Status](https://secure.travis-ci.org/Picklive/omniconf.png)](http://travis-ci.org/#!/Picklive/omniconf)

A _RubyGem_ that provides an application-agnostic configuration merger.

# Setup

Configure and load desired back-ends by creating a new initializer:

- With a Rails application, just run `rails g omniconf:install`.
- Without a Rails application, you need to create a file along these lines (see below):

```ruby
Omniconf.setup do |config|
  config.sources = {
    :yaml => {
      :type => :yaml,
      :file => "config/settings.yml"
    },
    :database => {
      :type => :active_record,
      :model => "ConfigValue"
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
> Omniconf.configuration.api # returns a hash if nested
 => {"username"=>"root"}
> Omniconf.configuration.non_existant # returns nil
 => nil
> Omniconf.configuration.non_existant.config_value # raises an exception
 => NoMethodError: undefined method `config_value' for nil:NilClass
```

## Setting values

```ruby
> Omniconf.configuration.some_config_from_database = "def" # updates value in DB using ConfigValue model
 => "def"
> Omniconf.configuration.some_config_from_yaml = 456 # raises an exception because the value comes from YAML
 => Omniconf::ReadOnlyConfigurationValue: cannot set 'some_config_from_yaml' because it belongs to a read-only back-end source (id: :yaml, type: Yaml)
> Omniconf.configuration.api.username = "admin" # it works with nested values too
 => "admin"
> Omniconf.configuration.brand_new_value = "whatever" # raises an exception because you've got to tell which back-end will store the new value
 => Omniconf::UnknownConfigurationValue: cannot set a configuration value with no parents
> Omniconf.sources[:database].brand_new_value = "whatever" # adds a new record in ConfigValue model
 => "whatever"
```

## Back-end sources

`:type` is the only required parameter.
Other parameters default to standard values for Rails.

### Yaml

_Note: read-only._

#### Parameters

- `:type => :yaml`
- `:file`: path to the YAML file to load (default: `config/settings.yml`)
- `:environment`: the root node to load from your YAML file (typically `development`, `production`, etc.)

### ActiveRecord

#### Setup

- Add `gem 'activerecord'` in your `Gemfile`.
- With a Rails application, `rails g omniconf:install` has already created a migration for you.
- Without a Rails application, create a new migration to add the config table:

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

#### Parameters

- `:type => :active_record`
- `:model`: name of the ActiveRecord model (default: `ConfigValue`)
- `:config_file`: path to the database settings (default: `config/database.yml`)
- `:environment`: environment to load (typically `development`, `production`, etc.)

## Reserved words

/!\ You should not use these names as configuration keys:

- `to_hash`: returns the configuration as a hash
- `inspect`: outputs sub-values as a hash
- `get_or_default`: returns the value if it exists or creates it otherwise (usage: `get_or_default(key, default_value)`)
- `method_missing`: used internally
- everything which starts with `__` (double underscore): used internally

# Testing

`rake`

Tested against _ree_, _ruby-1.9.2_ and _ruby-1.9.3_ thanks to [Travis CI](http://travis-ci.org/#!/Picklive/omniconf "It rocks!").

# License

MIT

