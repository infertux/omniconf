require 'spec_helper'
require 'omniconf/adapters/yaml'

describe Omniconf::Adapter::Yaml do
  def load_configuration env
    @adapter = Omniconf::Adapter::Yaml.new(:yaml_conf, {
      :environment => env,
      :file => File.join(File.dirname(__FILE__),
        '../../fixtures/omniconf/adapters/yaml/config/settings.yml'
      )
    })
    @adapter.load_configuration!
  end


  describe "#configuration" do
    def config
      @adapter.configuration
    end

    before do
      Omniconf.stub(:merge_configuration!)
      load_configuration('test')
    end

    describe "getting values" do
      it "returns a value" do
        config.yaml_key.should == 'yaml_value'
      end

      it "returns a nested value" do
        config.nested.yaml_key.should == 'nested_yaml_value'
      end
    end

    describe "setting values" do
      it "fails to update a value" do
        config.yaml_key.should_not be_nil
        expect {
          config.yaml_key = 'whatever'
        }.to raise_error Omniconf::ReadOnlyConfigurationValue
      end

      it "fails to update a nested value" do
        config.nested.yaml_key.should_not be_nil
        expect {
          config.nested.yaml_key = 'whatever'
        }.to raise_error Omniconf::ReadOnlyConfigurationValue
      end

      it "fails to create a value" do
        config.new_yaml_key.should be_nil
        expect {
          config.new_yaml_key = 'whatever'
        }.to raise_error Omniconf::ReadOnlyConfigurationValue
      end

      it "fails to create a nested value" do
        config.nested.new_yaml_key.should be_nil
        expect {
          config.nested.new_yaml_key = 'whatever'
        }.to raise_error Omniconf::ReadOnlyConfigurationValue
      end
    end

    describe "#get_or_default" do
      it "fails to create a new default value" do
        config.newValue.should be_nil
        expect {
          config.get_or_default('newValue', 'a').should == 'a'
        }.to raise_error Omniconf::ReadOnlyConfigurationValue
        config.newValue.should be_nil
      end

      it "fails to create a new nested default value" do
        config.nested.newValue.should be_nil
        expect {
          config.nested.get_or_default('newValue', 'a').should == 'a'
        }.to raise_error Omniconf::ReadOnlyConfigurationValue
        config.nested.newValue.should be_nil
      end
    end

    it "loads the right environment" do
      load_configuration 'development'
      config.yaml_key.should == 'yaml_value_dev'
    end

    it "keeps value types" do
      config.some_integer.should == 1337
      config.some_float.should == 3.14
      config.some_array.should == [1, 2, 3]
    end
  end
end

