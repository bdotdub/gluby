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

    context "has valid credentials" do
      setup do
        stub_get("/user/validate", "authentication/success.xml")
        @client.login("username", "password")
      end

      should "be authenticated" do
        @client.should  be_authenticated
        Gluepi.should   be_logged_in
      end
    end

    context "has invalid credentials" do
      setup do
        stub_get("/user/validate", "authentication/failed.xml")
        @client.login("username", "password")
      end

      should "not be authenticated" do
        @client.should_not  be_authenticated
        Gluepi.should_not   be_logged_in
      end
    end

  end

end


