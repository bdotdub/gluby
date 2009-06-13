require File.dirname(__FILE__) + '/../test_helper'

class ObjectTest < Test::Unit::TestCase

  def mock_object_from_object
    stub_get("/object/get?objectKey=mock_object", "object/get.xml")
    response = Gluby.get("/object/get",
                             :query => { :objectKey => 'mock_object' })
    Gluby::Object.from_object(response)
  end

  should "not be able to instantiate without objectKey" do
    lambda { Gluby::Object.new }.should raise_error

    object = Gluby::Object.new("movies/slumdog_millionaire/danny_boyle")
    object.should be_instance_of(Gluby::Object)
  end

  context "object instantiated" do
    context "with a valid key" do
      setup do
        stub_get("/object/users?objectId=movies%2Fslumdog_millionaire%2Fdanny_boyle", "object/get.xml")
        @object = Gluby::Object.get("movies/slumdog_millionaire/danny_boyle")
      end

      should "be a glue object" do
        @object.should be_glue_object
        @object.should be_instance_of(Gluby::MovieObject)
      end
    end

    context "with a bad key" do
      setup do
        stub_get("/object/get?objectId=blah", "errors/invalid_object.xml")
        @object = Gluby::Object.new("blah")
      end
      
      should "throw an invalid object error when getting a lazy loaded attribute" do
        lambda { @object.title }.should raise_error(Gluby::InvalidObject)
      end
    end

    context "with a URL not Glue Object" do
      setup do
        stub_get("/object/get?objectId=http%3A%2F%2Fwww.cnn.com%2F", "object/bookmark.xml")
        @object = Gluby::Object.get("http://www.cnn.com/")
      end

      should "be a bookmark object" do
        @object.should be_instance_of(Gluby::BookmarkObject)
      end

      should "not be a glue object" do
        @object.should_not be_glue_object
      end
    end

    should "be able to load an object with two categories" do
      stub_get("/object/get?objectId=http%3A%2F%2Fwww.ablog.com%2Fpost", "object/multiple_categories.xml")
      lambda { @object = Gluby::Object.get("http://www.ablog.com/post") }.should_not raise_error
      @object.should be_instance_of(Gluby::Object)
    end
  end

  should "be able to generate objects from factories" do
    stub_get("/object/get?objectKey=mock_object", "object/get.xml")
    response = Gluby.get("/object/get",
                             :query => { :objectKey => 'mock_object' })
    Gluby::Object.from_object(response).should be_kind_of(Gluby::Object)

    response = {"timestamp"=>"2009-05-29T04:28:17Z", "category"=>"movies", "title"=>"Slumdog Millionaire", "action"=>"Looked", "objectKey"=>"movies/slumdog_millionaire/danny_boyle", "userId"=>"spschessr", "image"=>"http://cdn-0.nflximg.com/us/boxshots/large/70095140.jpg", "source"=>{"name"=>"apple.com", "link"=>"http://www.apple.com/trailers/fox_searchlight/slumdogmillionaire"}}
    Gluby::Object.from_interaction(response).should be_kind_of(Gluby::Object)
  end

  should "should respond to the user attributes" do
    @mock_object = mock_object_from_object
    @mock_object.should respond_to( :objectKey,
                                    :title,
                                    :image, 
                                    :link, 
                                    :type,
                                    :description)
  end

  context "object is a movie object" do
    setup do
      @movie_object = mock_object_from_object
    end

    should "be an instance of MovieObject and a kind of Object" do
      @movie_object.should be_kind_of(Gluby::Object)
      @movie_object.should be_instance_of(Gluby::MovieObject)
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
      object = Gluby::Object.get(@objectKey)

      object.should_not be_nil
      object.should be_instance_of(Gluby::MovieObject)
    end

    should "return nil when objectKey is not found" do
      stub_get("/object/get?objectId=invalid_key", "errors/invalid_object.xml")
      object = Gluby::Object.get('invalid_key') 

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
      @interactions[0].should be_kind_of(Gluby::Interaction)
    end

    should "be the same object" do
      @interactions[0].object.class.should == @mock_object.class
    end

    should "have 250 of the latest interactions" do
      @interactions.length.should == 250
    end
  end

  context "links" do
    setup do
      stub_get("/object/links?objectId=movies%2Fslumdog_millionaire%2Fdanny_boyle", "object/links.xml")    
      @links = mock_object_from_object.links
    end

    should "return an array of links" do
      @links.should be_instance_of(Array)
    end
  end

  context "private actions" do
    setup do
    end

    should "not be able to add 2 cents longer than 160 characters" do
      @object = Gluby::Object.new('movies/ying_xiong/yimou_zhang')
      two_cents = 'abc' * 60
      lambda { @object.add2cents(two_cents) }.should raise_error(Gluby::TooManyCharacters)
    end

    context "valid object" do
      setup do
        # Add
        stub_get('/user/addVisit?source=http%3A%2F%2Fgithub.com%2Fbdotdub%2Fgluby&objectId=movies%2Fying_xiong%2Fyimou_zhang&app=Gluby', 'interactions/visit.xml')
        stub_get('/user/addLike?source=http%3A%2F%2Fgithub.com%2Fbdotdub%2Fgluby&objectId=movies%2Fying_xiong%2Fyimou_zhang&app=Gluby', 'interactions/visit.xml')
        stub_get('/user/add2Cents?source=http%3A%2F%2Fgithub.com%2Fbdotdub%2Fgluby&comment=this%20is%20a%20comment&objectId=movies%2Fying_xiong%2Fyimou_zhang&app=Gluby', 'interactions/visit.xml')

        # Remove
        stub_get('/user/removeVisit?objectId=movies%2Fying_xiong%2Fyimou_zhang', 'object/success.xml')
        stub_get('/user/removeLike?objectId=movies%2Fying_xiong%2Fyimou_zhang', 'object/success.xml')
        stub_get('/user/remove2Cents?objectId=movies%2Fying_xiong%2Fyimou_zhang', 'object/success.xml')

        @object = Gluby::Object.new('movies/ying_xiong/yimou_zhang')
      end

      should "return an interaction for add actions" do
        @object.visit.should be_kind_of(Gluby::Interaction)
        @object.like.should be_kind_of(Gluby::Interaction)
        @object.add2cents('this is a comment').should be_kind_of(Gluby::Interaction)
      end

      should "return success for remove actions" do
        @object.unvisit.should == :success
        @object.unlike.should == :success
        @object.remove2cents.should == :success
      end
    end

    context "invalid object" do
      setup do
        # Add
        stub_get('/user/addVisit?source=http%3A%2F%2Fgithub.com%2Fbdotdub%2Fgluby&objectId=movies%2Fying_xiong%2Fyimou_zhang&app=Gluby', 'errors/invalid_object.xml')
        stub_get('/user/addLike?source=http%3A%2F%2Fgithub.com%2Fbdotdub%2Fgluby&objectId=movies%2Fying_xiong%2Fyimou_zhang&app=Gluby', 'errors/invalid_object.xml')
        stub_get('/user/add2Cents?source=http%3A%2F%2Fgithub.com%2Fbdotdub%2Fgluby&comment=this%20is%20a%20comment&objectId=movies%2Fying_xiong%2Fyimou_zhang&app=Gluby', 'errors/invalid_object.xml')

        # Remove
        stub_get('/user/removeVisit?objectId=movies%2Fying_xiong%2Fyimou_zhang', 'errors/invalid_object.xml')
        stub_get('/user/removeLike?objectId=movies%2Fying_xiong%2Fyimou_zhang', 'errors/invalid_object.xml')
        stub_get('/user/remove2Cents?objectId=movies%2Fying_xiong%2Fyimou_zhang', 'errors/invalid_object.xml')

        @object = Gluby::Object.new('movies/ying_xiong/yimou_zhang')
      end

      should "raise invalid object exception for add actions" do
        lambda { @object.visit }.should raise_error(Gluby::InvalidObject)
        lambda { @object.like }.should raise_error(Gluby::InvalidObject)
        lambda { @object.add2cents('this is a comment') }.should raise_error(Gluby::InvalidObject)
      end

      should "raise invalid object exception remove actions" do
        lambda { @object.unvisit }.should raise_error(Gluby::InvalidObject)
        lambda { @object.unlike }.should raise_error(Gluby::InvalidObject)
        lambda { @object.remove2cents }.should raise_error(Gluby::InvalidObject)
      end
    end
  end
end

