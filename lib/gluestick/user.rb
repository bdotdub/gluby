module Gluestick
  class User
    attr_reader :username

    def initialize(username)
      @username = username
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
      @services = @services['service']
    end
  end
end
