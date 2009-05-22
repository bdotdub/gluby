module Gluepi
  class Client
    include Singleton
    include HTTParty

    API_URI   = "http://api.getglue.com/v1"
    base_uri  API_URI
    format    :xml

    def login(username, password)
      basic_auth  = { :username => username, :password => password }
      response    = unauthenticated_get("/user/validate", :basic_auth => basic_auth)

      @authenticated =  (!response.respond_to?(:error) || response.error.nil?) &&
                        response.response.key?('success')

      if @authenticated
        @username = username
        @password = password
      end
    end

    def authenticated?
      @authenticated || false
    end

    private

    def unauthenticated_get(*args)
      response = self.class.get(*args)
      parse_response(response)
    end

    def unauthenticated_post(*args)
      response = self.class.post(*args)
      parse_response(response)
    end

    def parse_response(response)
      response_object = Gluepi::Response.new

      response["adaptiveblue"].each_pair do |k,v|
        unless response_object.respond_to?(k.to_sym)
          response_object.class.class_eval do
            attr_reader k
          end
        end
        response_object.instance_variable_set("@#{k.to_s}", v)
      end

      response_object
    end

  end
end

