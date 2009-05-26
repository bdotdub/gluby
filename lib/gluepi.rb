require 'singleton'
require 'forwardable'
require 'httparty'

require 'gluepi/client'
require 'gluepi/response'
require 'gluepi/errors'

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
  
end


