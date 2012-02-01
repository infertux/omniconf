require 'spec_helper'
require 'omniconf/adapters/yaml'

describe Omniconf::Adapter::Yaml do
  def load_environment env
    @yaml = Omniconf::Adapter::Yaml.new({
      :environment => env,
      :file => File.join(File.dirname(__FILE__),
        '../../fixtures/omniconf/adapters/yaml/config/settings.yml'
      )
    })
    @yaml.load_configuration!
  end

  it "allows to get nested attributes" do
    load_environment 'test'
    @yaml.configuration.api.username.should == 'test_user'
    @yaml.configuration.api.password.should == 'test_password'
  end

  it "loads the right environment" do
    load_environment 'development'
    @yaml.configuration.api.username.should == 'user'
    @yaml.configuration.api.password.should == 'pass'
  end
end

