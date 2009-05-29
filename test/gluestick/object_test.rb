require File.dirname(__FILE__) + '/../test_helper'

class ObjectTest < Test::Unit::TestCase

  def mock_object_from_object
    stub_get("/object/get?objectId=mock_object", "object/get.xml")
    response = Gluestick::Client.instance.get("/object/get",
                                              :query => { :objectId => 'mock_object' })
    Gluestick::Object.from_object(response)
  end

  should "not be able to instantiate an interaction" do
    lambda { Gluestick::Object.new }.should raise_error
  end

  should "be able to generate objects from factories" do
    stub_get("/object/get?objectId=mock_object", "object/get.xml")
    response = Gluestick::Client.instance.get("/object/get",
                                              :query => { :objectId => 'mock_object' })
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



end

