module Gluepi
  class Client
    include Singleton
    include HTTParty

    base_uri  "http://api.getglue.com/v1"
    format    :plain

    def login(username, password)
      # basic_auth        = { :username => username, :password => password }
      # response_as_hash  = self.class.get("/user/validate", :basic_auth => basic_auth)
    end

    def authenticated?
      @authenticated
    end
  end
end

