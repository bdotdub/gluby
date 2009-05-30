require 'test_helper'

class GluestickTest < Test::Unit::TestCase

should "respond to client attributes" do
  Gluestick.should respond_to(:client, :login, :username)
end

context "client" do
  should "have a client" do
    Gluestick.client.should_not be_nil
  end

  should "be the client singleton" do
    Gluestick.client.should == Gluestick::Client.instance
  end
end

context "username" do
  context "logged in" do
    setup do
      stub_login
    end

    should "have a username" do
      Gluestick.username.should_not be_nil
      Gluestick.username.should == "username"
    end
  end

  context "not logged in" do
    setup do
      Gluestick.logout if Gluestick.logged_in?
    end

    teardown do
      stub_login if not Gluestick.logged_in?
    end

    should "not have a username" do
      Gluestick.username.should be_nil
    end
  end
end

end


