require File.dirname(__FILE__) + '/../test_helper'

class ErrorTest < Test::Unit::TestCase

  should "get an internal server error when return code is 500" do
    stub_login
    stub_get("/user/invalid", "blank.xml", 500)

    lambda { Gluepi.client.get("/user/invalid") }.should raise_error(Gluepi::InternalServerError)
  end

end


