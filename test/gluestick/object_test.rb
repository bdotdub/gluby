require File.dirname(__FILE__) + '/../test_helper'

class ObjectTest < Test::Unit::TestCase

  def mock_object_from_object
    stub_get("/object/get?objectKey=mock_object", "object/get.xml")
    response = Gluestick.get("/object/get",
                             :query => { :objectKey => 'mock_object' })
    Gluestick::Object.from_object(response)
  end

  should "not be able to instantiate an interaction" do
    lambda { Gluestick::Object.new }.should raise_error
  end

  should "be able to generate objects from factories" do
    stub_get("/object/get?objectKey=mock_object", "object/get.xml")
    response = Gluestick.get("/object/get",
                             :query => { :objectKey => 'mock_object' })
    Gluestick::Object.from_object(response).should be_kind_of(Gluestick::Object)

    response = {"timestamp"=>"2009-05-29T04:28:17Z", "category"=>"movies", "title"=>"Slumdog Millionaire", "action"=>"Looked", "objectKey"=>"movies/slumdog_millionaire/danny_boyle", "userId"=>"spschessr", "image"=>"http://cdn-0.nflximg.com/us/boxshots/large/70095140.jpg", "source"=>{"name"=>"apple.com", "link"=>"http://www.apple.com/trailers/fox_searchlight/slumdogmillionaire"}}
    Gluestick::Object.from_interaction(response).should be_kind_of(Gluestick::Object)
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

  context "users call" do
    setup do
      stub_get("/object/users?objectId=movies%2Fslumdog_millionaire%2Fdanny_boyle", "interactions/users.xml")
      stub_get("/object/get?objectId=mock_object", "object/get.xml")

      @mock_object = mock_object_from_object
      @interactions = @mock_object.users
    end

    should "return with an array in interactions" do
      @interactions.should be_instance_of(Array)
      @interactions[0].should be_kind_of(Gluestick::Interaction)
    end

    should "be the same object" do
      @interactions[0].object.class.should == @mock_object.class
    end

    should "have 250 of the latest interactions" do
      @interactions.length.should == 250
    end
  end

end

