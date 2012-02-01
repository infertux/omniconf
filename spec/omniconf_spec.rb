require 'spec_helper'
require 'omniconf'

describe Omniconf do

  describe "#setup" do
    it "reads the settings" do
      Omniconf.setup do |config|
        config.load_configuration = false
        config.sources = {
          :yaml_conf => {:type => :yaml, :file => "settings.yml"}
        }
      end

      Omniconf.settings.sources[:yaml_conf][:file].should == "settings.yml"
    end
  end

  describe "#load_configuration!" do
    def setup
      Omniconf.setup do |config|
        config.load_configuration = false
        config.sources = {
          :yaml => {
            :type => :yaml,
            :environment => 'test',
            :file => File.join(File.dirname(__FILE__),
              'fixtures/omniconf/adapters/yaml/config/settings.yml'
            )
          },
          :database => {
            :type => :active_record,
            :model_name => :ConfigValue,
            :environment => 'test',
            :config_file => File.join(File.dirname(__FILE__),
              'fixtures/omniconf/adapters/active_record/config/database.yml'
            )
          }
        }
      end
    end

    def insert_db_fixtures
      @database = Omniconf.settings.sources[:database][:adapter]
      @database.setup

      require File.join(File.dirname(__FILE__),
        'fixtures/omniconf/adapters/active_record/db/schema.rb'
      )
    end

    it "loads and merges all configurations" do
      setup
      insert_db_fixtures

      Omniconf.load_configuration!

      Omniconf.configuration.api.password.should == 'test_password'
      Omniconf.configuration.foo.should == 'bar'
    end
  end
end

