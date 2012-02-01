*THIS STUFF IS STILL ALPHA!*

# Setup

Configure and load desired backends by creating a new initializer `config/initializers/omniconf.rb`:

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

## Backend sources

`:type` is the only required parameter.
Other parameters default to standard values for Rails.

### Yaml

Nothing to configure apart from a YAML file.

_Note: read-only._

### ActiveRecord

Add `gem 'activerecord'` in your `Gemfile`.

Create a new migration to add the config table: _(FIXME: add a rake task for this)_

    class CreateConfigValues < ActiveRecord::Migration
      def change
        create_table :config_values do |t|
          t.string :key, :null => false
          t.string :value, :null => false
        end
        add_index :config_values, :key, :unique => true
      end
    end

### Redis

Add `gem 'redis'` in your `Gemfile`.

Not yet implemented.

# Testing

`rake`

Tested on _ree-1.8.7_ and _ruby-1.9.3_.

