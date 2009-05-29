require File.dirname(__FILE__) + '/../test_helper'

class InteractionTest < Test::Unit::TestCase

  should "should respond to the user attributes" do
    Gluestick::Interaction.new.should respond_to(:user,
                                                 :object,
                                                 :action)
  end

end

