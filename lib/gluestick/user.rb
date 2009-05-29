module Gluestick
  class User
    attr_reader :username

    def initialize(username)
      @username = username
    end

    def followers
      response = Gluestick::Client.instance.get("/user/followers", :query => { :userId => @username })
      @followers = response.response['followers']['userId']
      @followers = @followers.map{ |follower| User.new(follower) }
    end

    def friends
      response = Gluestick::Client.instance.get("/user/friends", :query => { :userId => @username })
      @friends = response.response['friends']['userId']
      @friends = @friends.map{ |friend| User.new(friend) }
    end

    def follow(other_user)
      other_user = other_user.username if other_user.instance_of?(Gluestick::User)

      response = Gluestick::Client.instance.get("/user/follow", :query => { :userId => other_user })
      result = response.response.keys.select{ |key| ['success', 'pending'].include?(key) }
      (result.length > 0) ? result[0] : nil;
    end

    def unfollow(other_user)
      other_user = other_user.username if other_user.instance_of?(Gluestick::User)

      response = Gluestick::Client.instance.get("/user/unfollow", :query => { :userId => other_user })
      'success' if response.response.has_key?('success')
      result = response.response.keys.select{ |key| ['success', 'pending'].include?(key) }
    end

    def private?
      get_user_profile if not instance_variable_defined?("@private")
      eval @private
    end

    # Create the accessors for the attributes that come from the profile call
    %w[display_name description favorites services].each do |property|
      define_method(property) do
        get_user_profile if not instance_variable_defined?("@#{property}")
        instance_variable_get("@#{property}")
      end
    end

    private

    def get_user_profile
      response = Gluestick::Client.instance.get("/user/profile", :query => { :userId => @username })
      response.response['profile'].each do |key, value|
        underscored_key = key.gsub(/[A-Z]/) do |p| '_' + p.downcase end
        instance_variable_set("@#{underscored_key}", value)
      end
    
      # Since httparty's xml deserialization is a little weird, we need to
      # hack it a bit
      @services = @services['service'] if @services
    end
  end
end
