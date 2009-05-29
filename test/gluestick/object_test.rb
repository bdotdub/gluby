require File.dirname(__FILE__) + '/../test_helper'

class ObjectTest < Test::Unit::TestCase

  def mock_object_from_object
    stub_get("/object/get?objectKey=mock_object", "object/get.xml")
    response = Gluestick::Client.instance.get("/object/get",
                                              :query => { :objectKey => 'mock_object' })
    Gluestick::Object.from_object(response)
  end

  should "not be able to instantiate an interaction" do
    lambda { Gluestick::Object.new }.should raise_error
  end

  should "be able to generate objects from factories" do
    stub_get("/object/get?objectKey=mock_object", "object/get.xml")
    response = Gluestick::Client.instance.get("/object/get",
                                              :query => { :objectKey => 'mock_object' })
    Gluestick::Object.from_object(response).should be_kind_of(Gluestick::Object)
  end

  should "should respond to the user attributes" do
    @mock_object = mock_object_from_object
    @mock_object.should respond_to( :objectKey,
                                    :title,
                                    :image, 
                                    :link, 
                                    :type)
  end

  context "object is a movie object" do
    setup do
      @movie_object = mock_object_from_object
    end

    should "be an instance of MovieObject and a kind of Object" do
      @movie_object.should be_kind_of(Gluestick::Object)
      @movie_object.should be_instance_of(Gluestick::MovieObject)
    end

    should "be able to access director" do
      @movie_object.should respond_to(:director)
      @movie_object.director.should == "Danny Boyle"
    end
  end

  context "get object by objectKey" do
    setup do
      @objectKey = @escapedObjectKey = "http://www.amazon.com/dp/B001P9KR8U/"
      @escapedObjectKey = URI.escape(@escapedObjectKey, "/")
      @escapedObjectKey = URI.escape(@escapedObjectKey, ":")
    end
    
    should "be able to find valid objectKey" do
      stub_get("/object/get?objectId=#{@escapedObjectKey}", "object/get.xml")
      object = Gluestick::Object.get(@objectKey)

      object.should_not be_nil
      object.should be_instance_of(Gluestick::MovieObject)
    end

    should "return nil when objectKey is not found" do
      stub_get("/object/get?objectId=invalid_key", "errors/invalid_object.xml")
      object = Gluestick::Object.get('invalid_key') 

      object.should be_nil
    end
  end

end

