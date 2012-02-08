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

  context "with some fixtures" do
    before do
      Omniconf.setup do |config|
        config.load_configuration = true
        config.sources = {
          :yaml => {
            :type => :yaml,
            :environment => 'test',
            :file => File.expand_path(
              '../fixtures/omniconf/adapters/yaml/config/settings.yml', __FILE__
            )
          },
          :database => {
            :type => :active_record,
            :model_name => :ConfigValue,
            :environment => 'test',
            :config_file => File.expand_path(
              '../fixtures/omniconf/adapters/active_record/config/database.yml',
              __FILE__
            )
          }
        }
      end

      # insert some fixtures into DB
      load File.expand_path(
        '../fixtures/omniconf/adapters/active_record/db/schema.rb', __FILE__
      )

      Omniconf.reload_configuration!
    end

    describe "#configuration" do
      def config
        Omniconf.configuration
      end

      it "returns an instance of Omniconf::Configuration" do
        config.should be_an_instance_of Omniconf::Configuration
      end

      describe "getting values" do
        it "loads and merges all configurations" do
          config.yaml_key.should == 'yaml_value'
          config.nested.yaml_key.should == 'nested_yaml_value'
          config.ar_key.should == 'ar_value'
          config.nested.ar_key.should == 'nested_ar_value'
        end
      end

      describe "setting values" do
        it "updates a value on its original source" do
          db_adapter = Omniconf.settings.sources[:database][:adapter]
          db_adapter.should_receive(:set_value).with(['ar_key'], 'new_ar_value')

          config.ar_key = 'new_ar_value'

          config.ar_key.should == 'new_ar_value'
          Omniconf.sources[:database].ar_key.should == 'new_ar_value'
        end

        it "creates a new value on the given source" do
          config.new_value.should be_nil
          db_adapter = Omniconf.settings.sources[:database][:adapter]
          db_adapter.should_receive(:set_value).with(['new_value'], 'new_ar_value')

          Omniconf.sources[:database].new_value = 'new_ar_value'

          Omniconf.sources[:database].new_value.should == 'new_ar_value'
          config.new_value.should == 'new_ar_value'
        end

        it "fails to create a new value with no sources" do
          # How the hell would I know where to store it?!
          config.no.should be_nil
          expect {
            config.no = 'whatever'
          }.to raise_error Omniconf::UnknownConfigurationValue
        end

        it "fails to create a new value with no parents" do
          db_adapter = Omniconf.settings.sources[:database][:adapter]
          Omniconf.sources[:database].no.should be_nil

          expect {
            Omniconf.sources[:database].no.no = 'new_ar_value'
          }.to raise_error Omniconf::UnknownConfigurationValue
        end
      end
    end
  end
end

