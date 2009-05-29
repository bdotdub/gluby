require File.dirname(__FILE__) + '/../test_helper'

class ObjectTest < Test::Unit::TestCase

  should "should respond to the user attributes" do
    Gluestick::Object.new.should respond_to(:objectKey, :type)
  end

end

