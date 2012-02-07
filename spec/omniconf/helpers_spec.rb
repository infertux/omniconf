require 'spec_helper'
require 'omniconf/helpers'

describe Hash do
  describe "#recursive_stringify_keys!" do
    it "stringify hash's keys recursively" do
      hash = {:a => 1, :b => {:aa => {:aaa => 'AAA', 'bbb' => nil}}}
      hash.recursive_stringify_keys!
      hash.should == {'a' => 1, 'b' => {'aa' => {'aaa' => 'AAA', 'bbb' => nil}}}
    end
  end
end

