require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

  should "should respond to the user attributes" do
    Gluby::User.new('someuser').should respond_to(:username,
                                                      :display_name,
                                                      :description)
  end
  
  should "username should be the one it was initialized with" do
    username = "someuser"
    @user = Gluby::User.new(username)
  
    @user.username.should == username
  end
  
  context "profile" do
    setup do
      stub_login
      stub_get("/user/profile?userId=mtab", "user/profile.xml")
      @user = Gluby::User.new('mtab')
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
      followers = Gluby::User.new("someuser").followers
  
      followers.class.should  == Array
      followers.length.should ==  10
    end
  
    should "be instances of User" do
      stub_get("/user/followers?userId=someuser", "user/followers.xml")
      followers = Gluby::User.new("someuser").followers
      followers[0].should be_instance_of(Gluby::User)
      
      stub_get("/user/friends?userId=someuser", "user/friends.xml")
      friends = Gluby::User.new("someuser").friends
      friends[0].should be_instance_of(Gluby::User)
    end
  
    should "have more multiple friends" do
      stub_get("/user/friends?userId=someuser", "user/friends.xml")
      friends = Gluby::User.new("someuser").friends
  
      friends.class.should  == Array
      friends.length.should == 9
    end
  
    should "have no friends and be ok" do
      stub_get("/user/friends?userId=someloser", "user/no_friends.xml")
      friends = Gluby::User.new("someloser").friends
  
      friends.class.should  == Array
      friends.length.should == 0
    end
  end
  
  context "getting user objects" do
    setup do
      stub_get("/user/objects?userId=someuser", "user/objects.xml")
      @user = Gluby::User.new('someuser')
      @interactions = @user.objects
    end

    should "return an array of interactions" do
      @interactions.should be_instance_of(Array)
      @interactions[0].should be_kind_of(Gluby::Interaction)
    end

    should "have multiple objects" do
      @interactions.length.should > 0
    end
  end

  context "getting object" do
    setup do
      stub_get("/user/object?userId=someuser&objectId=movies%2Fslumdog_millionaire%2Fdanny_boyle", "user/object.xml")
      @objectKey = "movies/slumdog_millionaire/danny_boyle"
      @user = Gluby::User.new('someuser')
      @interaction = @user.object(@objectKey)
    end

    should "should return an object" do
      @interaction.object.should be_kind_of(Gluby::Object)
      @interaction.object.should be_instance_of(Gluby::MovieObject)
    end

    should "be the correct object" do
      @interaction.object.objectKey.should == @objectKey
    end
  end

  context "with another user" do
    context "who is a valid user" do
      setup do
        stub_get("/user/follow?followUserId=valid_user", "user/follow.xml")
        stub_get("/user/follow?followUserId=private_user", "user/follow_pending.xml")
        stub_get("/user/unfollow?unfollowUserId=valid_user", "user/unfollow.xml")

        @user = Gluby::User.new('valid_user')
        @private_user = Gluby::User.new('private_user')
      end

      should "be success if you follow a public user" do
        @user.follow.should == :success
      end

      should "be pending if you follow a private user" do
        @private_user.follow.should == :pending
      end

      should "be success if you unfollow someone" do
        @user.unfollow.should == :success
      end
    end

    context "who is an invalid user" do
      setup do
        stub_get("/user/follow?followUserId=invalid_user", "errors/invalid_user.xml")
        stub_get("/user/unfollow?unfollowUserId=invalid_user", "errors/invalid_user.xml")

        @invalid_user = Gluby::User.new('invalid_user')
      end

      should "raise an error when you follow or unfollow an invalid user" do
        lambda { @invalid_user.follow }.should raise_error(Gluby::InvalidUser)
        lambda { @invalid_user.unfollow }.should raise_error(Gluby::InvalidUser)
      end
    end
  end

end


