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



end


