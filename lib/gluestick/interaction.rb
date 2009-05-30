module Gluestick
  class Interaction
    LOOKED        = "Looked"
    LIKED         = "Liked"
    COMMENT       = "Comment"
    LIKED_COMMENT = "LikedComment"
    REPLY         = "Reply"

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
	
	    interaction = new
	    interaction.instance_variable_set("@user", user)
	    interaction.instance_variable_set("@object", object)
	    interaction.instance_variable_set("@action", action)

      interaction
    end

  end
end
