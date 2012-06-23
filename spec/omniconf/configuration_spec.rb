require 'spec_helper'
require 'omniconf/configuration'

describe Omniconf::Configuration do
  let(:hash) do
    {
      'key' => 'level0',
      'nested0' => {
        'key' => 'level1',
        'nested1' => {
          'key' => 'level2',
          'nested2' => {
            'answer' => 42
          }
        }
      }
    }
  end

  it "is blank slated" do
    # check we don't have the 40-ish methods inherited from the Object class
    Omniconf::Configuration.new(nil).hash.should be_nil
  end

  describe "#initialize" do
    it "takes a hash as argument" do
      expect { Omniconf::Configuration.new nil, hash }.to_not raise_error
    end
  end

  context "with a configuration" do
    before do
      @config = Omniconf::Configuration.new nil, hash
    end

    describe "getting values" do
      it "returns a value" do
        @config.key.should == 'level0'
      end

      it "returns a nested value" do
        @config.nested0.key.should == 'level1'
        @config.nested0.nested1.nested2.answer.should == 42
      end

      it "#nil? returns true for non-existant values" do
        @config.nope_404.should be_nil
      end

      it "is false when a non-existant value is coerced to a boolean" do
        (!!(@config.nope_404)).should == false
        (@config.nope_404 ? true : false).should == false
      end
    end

    describe "setting values" do
      it "updates a value" do
        @config.key.should_not == 'new_level0'
        @config.key = 'new_level0'
        @config.key.should == 'new_level0'
      end

      it "creates a new value" do
        @config.key2.should be_nil
        @config.key2 = 'new_value'
        @config.key2.should == 'new_value'
      end

      it "updates a nested value" do
        @config.to_hash.should == hash
        @config.nested0.nested1.key.should_not == :new
        @config.nested0.nested1.key = :new
        @config.nested0.nested1.key.should == :new
        expected = hash
        expected['nested0']['nested1']['key'] = :new
        @config.to_hash.should == expected
      end

      it "creates a new nested value" do
        @config.to_hash.should == hash
        @config.nested0.new.should be_nil
        @config.nested0.new = 'new_value'
        @config.nested0.new.should == 'new_value'
        expected = hash
        expected['nested0']['new'] = 'new_value'
        @config.to_hash.should == expected
      end
    end
  end
end

