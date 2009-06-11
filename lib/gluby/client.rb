module Gluby

  # = Gluby::Client -- The client that makes all the HTTP requests
  # 
  # In general, these methods are not called directly. These calls can
  # be made via the +Gluby+ module
  #
  class Client
    include Singleton
    include HTTParty

    # Base Glue API URI
    API_URI   = "http://api.getglue.com/v1"

    # Some +HTTParty+ config options
    base_uri  API_URI
    format    :xml

    # The username that the client is logged in as
    attr_reader :username

    # Authenticates using +username+ and +password+. Raises an +NotAuthenticated+
    # exception when login is invalid.
    def login(username, password)
      basic_auth  = { :username => username, :password => password }
      response    = unauthenticated_get("/user/validate", :basic_auth => basic_auth)

      # If the login failed, an exception will be thrown, so at this point, we can be sure
      # that we're logged in.
      @authenticated = true
      @username = username
      @password = password
    end

    # Deauthenticates the client.
    def logout
      @authenticated = false
      @username = @password = nil
    end

    # Returns whether or not the client is authenticated
    def authenticated?
      @authenticated || false
    end

    # Perform HTTP GET on the Glue API for +url+. +options+ are HTTParty options.
    # This mixes in the authentication stuff for the HTTParty call.
    def get(url, options = {})
      raise Gluby::NotAuthenticated unless self.authenticated?
      authentication = ({ :username => @username, :password => @password })
      options[:basic_auth] = authentication
      unauthenticated_get(url, options)
    end

    # Just like Gluby::Client::get, except it does an HTTP POST
    def post(url, options = {})
      raise Gluby::NotAuthenticated unless self.authenticated?
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
      check_and_raise_errors(response)
      Gluby::AdaptiveBlueResponse.new(response)
    end

    def check_and_raise_errors(response)
      return unless response.nil? or
                    (response.has_key?('adaptiveblue') &&
                    response['adaptiveblue'].has_key?('error')) or
                    response.code != 200

      if !response.nil? && response.has_key?('adaptiveblue')
        error_obj = nil
        ab_response = response['adaptiveblue']
        error = ab_response['error']

        case error['code'].to_i
          when 101 then
            raise Gluby::MissingParameter.new(error)
          when 201 then
            raise Gluby::NotAuthenticated
          when 202 then
            raise Gluby::PermissionError
          when 301 then
            raise Gluby::InvalidURL
          when 302 then
            raise Gluby::InvalidObject.new(error)
          when 303 then
            raise Gluby::InvalidInteraction
          when 304 then
            raise Gluby::InvalidUser
        end
      else
        case response.code
          when 500 then raise Gluby::InternalServerError
        end
      end
    end

  end
end

