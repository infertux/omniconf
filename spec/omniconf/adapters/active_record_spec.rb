require 'spec_helper'
require 'omniconf/adapters/active_record'

describe Omniconf::Adapter::ActiveRecord do
  before do
    @database = Omniconf::Adapter::ActiveRecord.new({
      :model_name => :ConfigValue,
      :environment => 'test',
      :config_file => File.join(File.dirname(__FILE__),
        '../../fixtures/omniconf/adapters/active_record/config/database.yml'
      )
    })
    @database.setup

    require File.join(File.dirname(__FILE__),
      '../../fixtures/omniconf/adapters/active_record/db/schema.rb'
    )

    @database.load_configuration!
  end

  describe "#model" do
    describe "#[]" do
      it "returns configuration values from database" do
        @database.model['foo'].should == 'bar'
        @database.model['foo2'].should == 'bar2'
      end

      pending "it doesn't cast values to String" # TODO serialize them and keep type
    end

    describe "#[]=" do
      it "sets configuration values into database" do
        @database.model['foo3'].should be_nil
        @database.model['foo3'] = 'bar3'
        @database.model['foo3'].should == 'bar3'
      end
    end

    describe "#get_or_default" do
      it "sets default value if new" do
        @database.model.get_or_default('newValue', 'a').should == 'a'
        @database.model.get_or_default('newValue', 'b').should == 'a'
      end
    end
  end
end

