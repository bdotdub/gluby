require 'singleton'
require 'forwardable'
require 'httparty'

require 'gluestick/client'
require 'gluestick/response'
require 'gluestick/errors'
require 'gluestick/user'

module Gluestick
  class << self
    extend Forwardable
    def_delegators :client, :login

    def client
      @client = Gluestick::Client.instance unless @client
      @client
    end

    def logged_in?
      self.client.authenticated?
    end
  end
  
end


