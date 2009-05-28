require File.dirname(__FILE__) + '/../test_helper'

class ErrorTest < Test::Unit::TestCase

  should "get an internal server error when return code is 500" do
    stub_login
    stub_get("/user/invalid", "blank.xml", 500)

    lambda { Gluestick.client.get("/user/invalid") }.should raise_error(Gluestick::InternalServerError)
  end

  should "get a MissingParameter error" do
    stub_login
    stub_get("/user/profile", "errors/missing_parameter.xml", 400);

    lambda { Gluestick.client.get("/user/profile") }.should raise_error(Gluestick::MissingParameter)
  end
  
  should "get a MissingObject error" do
    stub_login
    stub_get("/object/get?objectId=something", "errors/invalid_object.xml", 400);

    lambda { Gluestick.client.get("/object/get?objectId=something") }.should raise_error(Gluestick::InvalidObject)
  end

  context "error initialized with response" do
    setup do
      FakeWeb.clean_registry

      stub_login
      stub_get("/user/profile", "errors/missing_parameter.xml", 400);

    end

    should "respond to message, code, and name" do
      begin
        Gluestick.client.get("/user/profile")
      rescue Gluestick::MissingParameter => missing_object
        missing_object.should respond_to(:name)
        missing_object.should respond_to(:message)
        missing_object.should respond_to(:code)
      end
    end

    should "have the correct code and name" do
      begin
        Gluestick.client.get("/user/profile")
      rescue Gluestick::MissingParameter => missing_object
        missing_object.name.should == "MissingParameter"
        missing_object.code.should == 101
      end
    end

  end

end


