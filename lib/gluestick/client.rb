module Gluestick
  class Client
    include Singleton
    include HTTParty

    API_URI   = "http://api.getglue.com/v1"
    base_uri  API_URI
    format    :xml

    attr_reader :username

    def login(username, password)
      basic_auth  = { :username => username, :password => password }
      response    = unauthenticated_get("/user/validate", :basic_auth => basic_auth)

      @authenticated = (!response.kind_of? Gluestick::ErrorResponse)

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
      raise Gluestick::NotAuthenticated unless self.authenticated?
      authentication = ({ :username => @username, :password => @password })
      options[:basic_auth] = authentication
      unauthenticated_get(url, options)
    end

    def post(url, options = {})
      raise Gluestick::NotAuthenticated unless self.authenticated?
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

      response_object = Gluestick::AdaptiveBlueResponse.new

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
            raise Gluestick::MissingParameter.new(error)
          when 201 then
            raise Gluestick::NotAuthenticated
          when 202 then
            raise Gluestick::PermissionError
          when 301 then
            raise Gluestick::InvalidURL
          when 302 then
            raise Gluestick::InvalidObject.new(error)
          when 303 then
            raise Gluestick::InvalidInteraction
          when 304 then
            raise Gluestick::InvalidUser
        end
      else
        case response.code
          when 500 then raise Gluestick::InternalServerError
        end
      end
    end

  end
end

