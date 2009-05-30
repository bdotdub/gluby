module Gluestick
  class Interaction
    attr_reader           :user, :object, :action
    private_class_method  :new

    def self.from_response(response)
      raise TypeError if response.class != Gluestick::AdaptiveBlueResponse

      interactions  = interactions_xml = []
      username      = response.request['params']['userId'] || ''

      if (is_single_interaction = is_single_interaction?(response))
        interactions_xml = [response.response['interaction']]
      else
        interactions_xml = response.response['interactions']['interaction']
      end
      
      interactions_xml.each do |interaction_element|
	      interactions << generate_single_interaction(interaction_element, username)
      end
      
      is_single_interaction ? interactions[0] : interactions
    end

    private

    def self.create
      new
    end

    def self.is_single_interaction?(response)
      if response.response['interactions']
        false
      elsif response.response['interaction']
        true
      else
        raise "Invalid response"
      end
    end

    def self.generate_single_interaction(interaction_element, username)
	    interactive_user  = (interaction_element.has_key?('userId')) ? 
	                        interaction_element['userId'] :
	                        username
	
	    user    = Gluestick::User.new(username)
	    object  = Gluestick::Object.from_interaction(interaction_element)
	    action  = interaction_element['action']
	
	    interaction = create_for_action(action)
	    interaction.instance_variable_set("@user", user)
	    interaction.instance_variable_set("@object", object)
	    interaction.instance_variable_set("@action", action)

      interaction
    end

    def self.create_for_action(action)
      action = action.downcase
      # Would've extracted this out into a constant, but the classes
      # are not defined and throws NameErrors
	    @@interactions = {
        :looked        => Gluestick::LookedInteraction,
        :liked         => Gluestick::LikedInteraction,
        :comment       => Gluestick::CommentInteraction,
        :likedcomment  => Gluestick::LikedCommentInteraction,
        :reply         => Gluestick::ReplyInteraction
	    }
      
      if @@interactions.has_key?(action.to_sym)
        @@interactions[action.to_sym].create
      else
        create
      end
    end
  end

  class LookedInteraction < Interaction; end
  class LikedInteraction < Interaction; end
  class CommentInteraction < Interaction; end
  class LikedCommentInteraction < Interaction; end
  class ReplyInteraction < Interaction; end
end
