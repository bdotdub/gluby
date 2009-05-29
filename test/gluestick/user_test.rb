require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

should "should respond to the user attributes" do
  Gluestick::User.new('someuser').should respond_to(:username,
                                                    :display_name,
                                                    :description)
end

should "username should be the one it was initialized with" do
  username = "someuser"
  @user = Gluestick::User.new(username)

  @user.username.should == username
end

context "profile" do
  setup do
    stub_login
    stub_get("/user/profile?userId=mtab", "user/profile.xml")
    @user = Gluestick::User.new('mtab')
  end

  should "have a display_name and description" do
    @user.display_name.should == "Mark Tabry"
    @user.description.should  == "Software Engineer at AdaptiveBlue"
  end

  should "indicate whether it is private" do
    @user.should_not be_private
  end

  should "have two services defined" do
    @user.services.length.should == 2
  end

  should "have ten categories of favorites" do
    @user.favorites.keys.length.should == 10
  end
end

end


