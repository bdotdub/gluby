module Gluby
  class User
    extend Gluby::LazyLoader
    lazy_load([:display_name, :description, :favorites, :services, :private], :get_user_profile)

    attr_reader :username

    def initialize(username)
      @username = username
    end

    def followers
      response = Gluby.get("/user/followers", :query => { :userId => @username })
      @followers = begin response.response['followers']['userId'] rescue [] end
      @followers = @followers.map{ |follower| User.new(follower) }
    end

    def friends
      response = Gluby.get("/user/friends", :query => { :userId => @username })
      @friends = begin response.response['friends']['userId'] rescue [] end
      @friends = @friends.map{ |friend| User.new(friend) }
    end

    def objects
      response = Gluby.get("/user/objects", :query => { :userId => @username })
      Gluby::Interaction.from_response(response)
    end

    def object(objectId)
      response = Gluby.get("/user/object", :query => { :userId => @username, :objectId => objectId })
      Gluby::Interaction.from_response(response)
    end

    def follow
      response = Gluby.get("/user/follow", :query => { :followUserId => @username })
      return :success if response.response.has_key?('success')
      return :pending if response.response.has_key?('pending')
    end

    def unfollow
      response = Gluby.get("/user/unfollow", :query => { :unfollowUserId => @username })
      return :success if response.response.has_key?('success')
    end

    def private?
      eval self.private
    end

    private

    def get_user_profile
      response = Gluby.get("/user/profile", :query => { :userId => @username })
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
