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

      @authenticated = (!response.kind_of? Gluepi::ErrorResponse)

      if @authenticated
        @username = username
        @password = password
      end
    end

    def logout
      if self.authenticated?
        @authenticated = false
        @username = @password = nil
      end
    end

    def authenticated?
      @authenticated || false
    end

    def get(url, options = {})
      raise Gluepi::NotAuthenticated unless self.authenticated?
      authentication = ({ :username => @username, :password => @password })
      options[:basic_auth] = authentication
      unauthenticated_get(url, options)
    end

    def post(url, options = {})
      raise Gluepi::NotAuthenticated unless self.authenticated?
      authentication = ({ :username => @username, :password => @password })
      options[:basic_auth] = authentication
      unauthenticated_post(url, options)
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
      if response['adaptiveblue'].has_key? 'error'
        return Gluepi::ErrorResponse.new
      end

      response_object = Gluepi::AdaptiveBlueResponse.new

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

