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

    def client
      @client = Gluestick::Client.instance unless @client
      @client
    end

    def get(*args)
      self.client.get(*args)
    end

    def post(*args)
      self.client.post(*args)
    end

    def logged_in?
      self.client.authenticated?
    end
  end
  
end


