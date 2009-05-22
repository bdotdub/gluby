require 'singleton'
require 'forwardable'
require 'httparty'

require 'gluepi/client'

module Gluepi
  class << self
    extend Forwardable
    def_delegators :client, :login

    def client
      @client = Gluepi::Client.instance unless @client
      @client
    end

    def logged_in?
      self.client.authenticated?
    end
  end
  
  # Generic classes
  class Response; end

  # Errors
  class NotAuthenticated < StandardError; end

end


