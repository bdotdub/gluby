require File.dirname(__FILE__) + '/../test_helper'

class ClientTest < Test::Unit::TestCase

  should "not be able to call 'new' on the singleton" do
    lambda { Gluepi::Client.new }.should raise_error  
  end

  should "be able to get the only instance" do
    lambda { Gluepi::Client.instance }.should_not raise_error
  end

  context "authentication" do
    setup do
      @client = Gluepi::Client.instance
    end

    should "be able to login" do
      @client.should respond_to(:login)
    end
    
    should "respond to authenticated?" do
      @client.should respond_to(:authenticated?)
    end

  end

end


