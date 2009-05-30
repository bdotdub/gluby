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
  
  context "followers and friends" do
    setup do
      stub_login
    end
  
    should "have more multiple followers" do
      stub_get("/user/followers?userId=someuser", "user/followers.xml")
      followers = Gluestick::User.new("someuser").followers
  
      followers.class.should  == Array
      followers.length.should ==  10
    end
  
    should "be instances of User" do
      stub_get("/user/followers?userId=someuser", "user/followers.xml")
      followers = Gluestick::User.new("someuser").followers
      followers[0].should be_instance_of(Gluestick::User)
      
      stub_get("/user/friends?userId=someuser", "user/friends.xml")
      friends = Gluestick::User.new("someuser").friends
      friends[0].should be_instance_of(Gluestick::User)
    end
  
    should "have more multiple friends" do
      stub_get("/user/friends?userId=someuser", "user/friends.xml")
      friends = Gluestick::User.new("someuser").friends
  
      friends.class.should  == Array
      friends.length.should == 9
    end
  
    should "have no friends and be ok" do
      stub_get("/user/friends?userId=someloser", "user/no_friends.xml")
      friends = Gluestick::User.new("someloser").friends
  
      friends.class.should  == Array
      friends.length.should == 0
    end
  end
  
  context "interactions with other users" do
    setup do
      stub_login
      @user = Gluestick::User.new("someuser")
    end
  
    should "be successful when following a public member" do
      stub_get("/user/follow?userId=someotheruser", "user/follow.xml")
      someotheruser = Gluestick::User.new("someotheruser")
  
      @user.follow("someotheruser").should  == "success"
      @user.follow(someotheruser).should    == "success"
    end
  
    should "be pending when requesting to follow a private user" do
      stub_get("/user/follow?userId=someprivateuser", "user/follow_pending.xml")
      someprivateuser = Gluestick::User.new("someprivateuser")
  
      @user.follow("someprivateuser").should  == "pending"
      @user.follow(someprivateuser).should    == "pending"
    end
  end

  context "getting user objects" do
    setup do
      stub_get("/user/objects?userId=someuser", "user/objects.xml")
      @user = Gluestick::User.new('someuser')
      @interactions = @user.objects
    end

    should "return an array of interactions" do
      @interactions.should be_instance_of(Array)
      @interactions[0].should be_kind_of(Gluestick::Interaction)
    end

    should "have multiple objects" do
      @interactions.length.should > 0
    end
  end

end


