require 'test_helper'

class GlubyTest < Test::Unit::TestCase

should "respond to client attributes" do
  Gluby.should respond_to(:client)
  Gluby.should respond_to(:login)
  Gluby.should respond_to(:username)
end

context "client" do
  should "have a client" do
    Gluby.client.should_not be_nil
  end

  should "be the client singleton" do
    Gluby.client.should == Gluby::Client.instance
  end
end

context "username" do
  context "logged in" do
    setup do
      stub_login
    end

    should "have a username" do
      Gluby.username.should_not be_nil
      Gluby.username.should == "username"
    end
  end

  context "not logged in" do
    setup do
      Gluby.logout if Gluby.logged_in?
    end

    teardown do
      stub_login if not Gluby.logged_in?
    end

    should "not have a username" do
      Gluby.username.should be_nil
    end
  end
end

end


