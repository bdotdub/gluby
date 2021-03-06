require File.dirname(__FILE__) + '/../test_helper'

class ClientTest < Test::Unit::TestCase

  should "not be able to call 'new' on the singleton" do
    lambda { Gluby::Client.new }.should raise_error  
  end

  should "be able to get the only instance" do
    lambda { Gluby::Client.instance }.should_not raise_error
  end

  context "client" do
    setup do
      @client = Gluby::Client.instance
    end

    teardown do
      FakeWeb.clean_registry
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

      teardown do
        @client.logout
      end

      should "be authenticated" do
        @client.should  be_authenticated
        Gluby.should   be_logged_in
      end

      should "get a valid response when calling API" do
        stub_get("/user/validate", "authentication/success.xml")
        @client.get("/user/validate").should be_kind_of(Gluby::AdaptiveBlueResponse)
      end

      should "get an error with missing parameters" do
        stub_get("/user/validate", "authentication/failed.xml")
        lambda { @client.get("/user/validate") }.should raise_error(Gluby::NotAuthenticated)
      end
    end

    context "has invalid credentials" do
      setup do
        stub_get("/user/validate", "authentication/failed.xml")
      end

      should "raise an error when logging in" do
        lambda { @client.login("username", "password") }.should raise_error(Gluby::NotAuthenticated)
      end

      should "not be authenticated" do
        @client.should_not  be_authenticated
        Gluby.should_not   be_logged_in
      end
    end

    context "is not logged in" do
      should "not be logged in" do
        Gluby.should_not be_logged_in
      end

      should "not be able to make an API call" do
        lambda { @client.get("/user/validate") }.should raise_error(Gluby::NotAuthenticated)
      end
    end

  end

  context "constructing request URI" do
    setup do
      @client = Gluby::Client.instance
      stub_login
    end

    should "call the correctly stubbed URI" do
      stub_get("/user/endpoint?param=value", "authentication/success.xml")

      lambda { @client.get("/user/endpoint") }.should raise_error
      lambda { @client.get("/user/endpoint", :query => { :param => 'value' }) }.should_not raise_error
    end
  end

end


