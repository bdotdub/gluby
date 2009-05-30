module Gluestick
  class User
    extend Gluestick::LazyLoader
    lazy_load([:display_name, :description, :favorites, :services, :private], :get_user_profile)

    attr_reader :username

    def initialize(username)
      @username = username
    end

    def followers
      response = Gluestick.get("/user/followers", :query => { :userId => @username })
      @followers = response.response['followers'].nil? ? [] : response.response['followers']['userId']
      @followers = @followers.map{ |follower| User.new(follower) }
    end

    def friends
      response = Gluestick.get("/user/friends", :query => { :userId => @username })
      @friends = response.response['friends'].nil? ? [] : response.response['friends']['userId']
      @friends = @friends.map{ |friend| User.new(friend) }
    end

    def follow(other_user)
      other_user = other_user.username if other_user.instance_of?(Gluestick::User)

      response = Gluestick.get("/user/follow", :query => { :userId => other_user })
      result = response.response.keys.select{ |key| ['success', 'pending'].include?(key) }
      (result.length > 0) ? result[0] : nil;
    end

    def unfollow(other_user)
      other_user = other_user.username if other_user.instance_of?(Gluestick::User)

      response = Gluestick.get("/user/unfollow", :query => { :userId => other_user })
      'success' if response.response.has_key?('success')
      result = response.response.keys.select{ |key| ['success', 'pending'].include?(key) }
    end

    def private?
      eval self.private
    end


    private

    def get_user_profile
      response = Gluestick.get("/user/profile", :query => { :userId => @username })
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
