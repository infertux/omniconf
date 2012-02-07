require 'spec_helper'
require 'omniconf/adapters/active_record'

describe Omniconf::Adapter::ActiveRecord do
  def load_configuration
    @adapter = Omniconf::Adapter::ActiveRecord.new(:active_record, {
      :model_name => :ConfigValue,
      :environment => 'test',
      :config_file => File.expand_path(
        '../../../fixtures/omniconf/adapters/active_record/config/database.yml',
        __FILE__
      )
    })
    @adapter.setup

    load File.expand_path(
      '../../../fixtures/omniconf/adapters/active_record/db/schema.rb', __FILE__
    )

    @adapter.load_configuration!
  end

  describe "#configuration" do
    before do
      Omniconf.stub(:merge_configuration!)
      load_configuration
    end

    let(:configuration) { @adapter.configuration }

    describe "getting values" do
      it "returns a value" do
        configuration.ar_key.should == 'ar_value'
      end

      it "returns a nested value" do
        configuration.nested.ar_key.should == 'nested_ar_value'
      end
    end

    describe "setting values" do
      it "updates configuration values into database" do
        configuration.ar_key.should == 'ar_value'
        configuration.ar_key = 'new_ar_value'
        configuration.ar_key.should == 'new_ar_value'
      end

      it "creates configuration values into database" do
        configuration.new_ar_key.should be_nil
        configuration.new_ar_key = 'new_ar_value'
        configuration.new_ar_key.should == 'new_ar_value'
      end

      it "it doesn't cast values to String" # TODO serialize them and keep type
    end

    describe "#get_or_default" do
      it "creates a new default value" do
        configuration.newValue.should be_nil
        @adapter.should_receive(:set_value).with(['newValue'], 'a')
        configuration.get_or_default('newValue', 'a').should == 'a'
        configuration.get_or_default('newValue', 'b').should == 'a'
      end

      it "creates a new default nested value" do
        configuration.nested.newValue.should be_nil
        @adapter.should_receive(:set_value).with(['nested', 'newValue'], 'a')
        configuration.nested.get_or_default('newValue', 'a').should == 'a'
        configuration.nested.get_or_default('newValue', 'b').should == 'a'
      end
    end
  end
end

