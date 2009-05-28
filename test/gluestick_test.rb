require 'test_helper'

class GluestickTest < Test::Unit::TestCase

context "client" do
  should "have a client" do
    Gluestick.should respond_to(:client)
    Gluestick.client.should_not be_nil
  end

  should "be the client singleton" do
    Gluestick.client.should == Gluestick::Client.instance
  end
end

context "login" do
  should "respond to login" do
    Gluestick.should respond_to(:login)
  end
end

end


