require 'singleton'
require 'forwardable'
require 'httparty'

require 'gluestick/lazy_loader'
require 'gluestick/client'
require 'gluestick/response'
require 'gluestick/errors'
require 'gluestick/user'
require 'gluestick/interaction'
require 'gluestick/object'

module Gluestick

  class << self
    extend Forwardable
    attr_reader     :username
    def_delegators  :client, :login, :logout, :username

    # Returns the singleton instance
    def client
      @client = Gluestick::Client.instance unless @client
      @client
    end

    # Perform a Glue API HTTP GET on URL with +HTTParty+ options. Returns an
    # +AdaptiveBlueResponse+ or raises an exception
    # 
    #   Gluestick.get("/user/get", :query => { :userId => 'someuser' }) 
    #
    def get(url, *args)
      self.client.get(url, *args)
    end

    # Perform a Glue API HTTP POST on URL with +HTTParty+ options. Returns an
    # +AdaptiveBlueResponse+ or raises an exception
    # 
    #   Gluestick.get("/user/get", :query => { :userId => 'someuser' }) 
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


