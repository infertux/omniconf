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
    before do
      Omniconf.stub(:merge_configuration!)
      load_configuration('test')
    end

    let(:configuration) { @adapter.configuration }

    describe "getting values" do
      it "returns a value" do
        configuration.yaml_key.should == 'yaml_value'
      end

      it "returns a nested value" do
        configuration.nested.yaml_key.should == 'nested_yaml_value'
      end
    end

    describe "setting values" do
      it "fails to update a value" do
        configuration.yaml_key.should_not be_nil
        expect {
          configuration.yaml_key = 'whatever'
        }.to raise_error Omniconf::ReadOnlyConfigurationValue
      end

      it "fails to update a nested value" do
        configuration.nested.yaml_key.should_not be_nil
        expect {
          configuration.nested.yaml_key = 'whatever'
        }.to raise_error Omniconf::ReadOnlyConfigurationValue
      end

      it "fails to create a value" do
        configuration.new_yaml_key.should be_nil
        expect {
          configuration.new_yaml_key = 'whatever'
        }.to raise_error Omniconf::ReadOnlyConfigurationValue
      end

      it "fails to create a nested value" do
        configuration.nested.new_yaml_key.should be_nil
        expect {
          configuration.nested.new_yaml_key = 'whatever'
        }.to raise_error Omniconf::ReadOnlyConfigurationValue
      end
    end

    describe "#get_or_default" do
      it "fails to create a new default value" do
        configuration.newValue.should be_nil
        expect {
          configuration.get_or_default('newValue', 'a').should == 'a'
        }.to raise_error Omniconf::ReadOnlyConfigurationValue
        configuration.newValue.should be_nil
      end

      it "fails to create a new nested default value" do
        configuration.nested.newValue.should be_nil
        expect {
          configuration.nested.get_or_default('newValue', 'a').should == 'a'
        }.to raise_error Omniconf::ReadOnlyConfigurationValue
        configuration.nested.newValue.should be_nil
      end
    end

    it "loads the right environment" do
      load_configuration 'development'
      configuration.yaml_key.should == 'yaml_value_dev'
    end
  end
end

