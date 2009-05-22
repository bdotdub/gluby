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
  end
end


