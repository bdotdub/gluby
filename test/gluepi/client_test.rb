require File.dirname(__FILE__) + '/../test_helper'

class ClientTest < Test::Unit::TestCase

  should "not be able to call 'new' on the singleton" do
    lambda { Gluepi::Client.new }.should raise_error  
  end

  should "be able to get the only instance" do
    lambda { Gluepi::Client.instance }.should_not raise_error
  end

  context "client" do
    setup do
      @client = Gluepi::Client.instance
    end

    should "be able to login" do
      @client.should respond_to(:login)
    end
    
    should "respond to authenticated?" do
      @client.should respond_to(:authenticated?)
    end

    context "authentication succeeded" do
      setup do
        stub_get("/user/validate", "authentication/success.xml")
        @client.login("username", "password")
      end

      should "be authenticated" do
        @client.should be_authenticated
        # Gluepi.logged_in?.should      be_true
      end
    end

  end

end


