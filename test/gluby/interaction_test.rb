require File.dirname(__FILE__) + '/../test_helper'

class InteractionTest < Test::Unit::TestCase

  should "not be able to instantiate an interaction" do
    lambda { Gluby::Interaction.new }.should raise_error
  end

  should "generate an interaction from a response" do
    stub_get("/object/users?objectId=someKey", "interactions/users.xml")
    response = Gluby.get("/object/users", :query => { :objectId => 'someKey' })

    lambda { Gluby::Interaction.from_response([]) }.should raise_error
    @interactions = Gluby::Interaction.from_response(response)
    @interactions.should be_instance_of(Array)
    @interactions[0].should be_kind_of(Gluby::Interaction)
  end

  should "return a single interaction if response is a single interaction" do
    stub_get("/user/addReply", "interactions/add_reply.xml")
    response = Gluby.get("/user/addReply")
    @interaction = Gluby::Interaction.from_response(response)

    @interaction.should be_instance_of(Gluby::ReplyInteraction)
    @interaction.should be_kind_of(Gluby::Interaction)
  end

  context "single interaction" do
    setup do
      stub_get("/user/profile?userId=someuser", "user/profile.xml")
      stub_get("/object/get?objectId=movies%2Fslumdog_millionaire%2Fdanny_boyle", "object/get.xml")

      stub_get("/user/addReply", "interactions/add_reply.xml")
      response = Gluby.get("/user/addReply")
      @interaction = Gluby::Interaction.from_response(response)
    end

    should "respond to type, user, and object" do
      @interaction.should respond_to(:type, :user, :object)
    end

    context "object" do
      should "be an instance of movieobject" do
        @interaction.object.should be_instance_of(Gluby::MovieObject)
      end

      should "be able to pull attributes" do
        @interaction.object.director.should == "Danny Boyle"
      end
    end

    context "user" do
      should "be of type User" do
        @interaction.user.should be_instance_of(Gluby::User)
      end

      should "be able to pull lazy loaded attributes" do
        @interaction.user.display_name.should == "Mark Tabry"
      end
    end
  end

  context "specific interactions" do
    context "liked comment" do
      setup do
        stub_get("/user/object", "user/object.xml")
        response = Gluby.get("/user/object")
        @interaction = Gluby::Interaction.from_response(response)
      end

      should "be a liked comment interaction" do
        @interaction.should be_instance_of(Gluby::LikedCommentInteraction)
      end

      should "have a comment" do
        @interaction.should respond_to(:comment)
        @interaction.comment.should_not be_empty
      end
    end
  end

end

