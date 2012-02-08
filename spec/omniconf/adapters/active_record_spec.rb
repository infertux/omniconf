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
    def config
      @adapter.configuration
    end

    before do
      Omniconf.stub(:merge_configuration!)
      load_configuration
    end

    describe "getting values" do
      it "returns a value" do
        config.ar_key.should == 'ar_value'
      end

      it "returns a nested value" do
        config.nested.ar_key.should == 'nested_ar_value'
      end
    end

    describe "setting values" do
      it "updates config values into database" do
        config.ar_key.should == 'ar_value'
        config.ar_key = 'new_ar_value'
        config.ar_key.should == 'new_ar_value'
      end

      it "creates config values into database" do
        config.new_ar_key.should be_nil
        config.new_ar_key = 'new_ar_value'
        config.new_ar_key.should == 'new_ar_value'
      end
    end

    describe "#get_or_default" do
      it "creates a new default value" do
        config.newValue.should be_nil
        @adapter.should_receive(:set_value).with(['newValue'], 'a')
        config.get_or_default('newValue', 'a').should == 'a'
        config.get_or_default('newValue', 'b').should == 'a'
      end

      it "creates a new default nested value" do
        config.nested.newValue.should be_nil
        @adapter.should_receive(:set_value).with(['nested', 'newValue'], 'a')
        config.nested.get_or_default('newValue', 'a').should == 'a'
        config.nested.get_or_default('newValue', 'b').should == 'a'
      end
    end

    it "keeps value types" do
      config.some_integer.should be_nil
      config.some_float.should be_nil
      config.some_array.should be_nil
      config.some_integer = 1337
      config.some_float = 3.14
      config.some_array = [1, 2, 3]
      @adapter.reload_configuration!
      config.some_integer.should == 1337
      config.some_float.should == 3.14
      config.some_array.should == [1, 2, 3]
    end
  end
end

