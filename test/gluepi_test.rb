require 'test_helper'

class GluepiTest < Test::Unit::TestCase

context "client" do
  should "have a client" do
    Gluepi.should respond_to(:client)
    Gluepi.client.should_not be_nil
  end

  should "be the client singleton" do
    Gluepi.client.should == Gluepi::Client.instance
  end
end

context "login" do
  should "respond to login" do
    Gluepi.should respond_to(:login)
  end
end

end


