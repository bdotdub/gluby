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
      @followers = begin response.response['followers']['userId'] rescue [] end
      @followers = @followers.map{ |follower| User.new(follower) }
    end

    def friends
      response = Gluestick.get("/user/friends", :query => { :userId => @username })
      @friends = begin response.response['friends']['userId'] rescue [] end
      @friends = @friends.map{ |friend| User.new(friend) }
    end

    def objects
      response = Gluestick.get("/user/objects", :query => { :userId => @username })
      Gluestick::Interaction.from_response(response)
    end

    def object(objectId)
      response = Gluestick.get("/user/object", :query => { :userId => @username, :objectId => objectId })
      Gluestick::Interaction.from_response(response)
    end

    def follow(other_user)
      other_user = other_user.username if other_user.instance_of?(Gluestick::User)
      response = Gluestick.get("/user/follow", :query => { :userId => other_user })

      result = nil
      ['success', 'pending'].each do |tag|
        result = tag if response.response.has_key?(tag)
      end

      result
    end

    def unfollow(other_user)
      other_user = other_user.username if other_user.instance_of?(Gluestick::User)
      response = Gluestick.get("/user/unfollow", :query => { :userId => other_user })

      response.response.has_key?('success') ? 'success' : nil
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
