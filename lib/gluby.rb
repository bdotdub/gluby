require 'singleton'
require 'forwardable'
require 'httparty'

require 'gluby/lazy_loader'
require 'gluby/client'
require 'gluby/response'
require 'gluby/errors'
require 'gluby/user'
require 'gluby/interaction'
require 'gluby/object'

module Gluby

  class << self
    extend Forwardable
    attr_reader     :username
    def_delegators  :client, :login, :logout, :username

    # Returns the singleton instance
    def client
      @client = Gluby::Client.instance unless @client
      @client
    end

    # Perform a Glue API HTTP GET on URL with +HTTParty+ options. Returns an
    # +AdaptiveBlueResponse+ or raises an exception
    # 
    #   Gluby.get("/user/get", :query => { :userId => 'someuser' }) 
    #
    def get(url, *args)
      self.client.get(url, *args)
    end

    # Perform a Glue API HTTP POST on URL with +HTTParty+ options. Returns an
    # +AdaptiveBlueResponse+ or raises an exception
    # 
    #   Gluby.get("/user/get", :query => { :userId => 'someuser' }) 
    #
    def post(url, *args)
      self.client.post(url, *args)
    end

    # Returns +true+ if you are logged in
    def logged_in?
      self.client.authenticated?
    end
  end
  
end


