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

      interactions        = []
      interactions_xml    = []
      username            = response.request['params']['userId'] || ''

      if response.response.has_key?('interactions')
        single_interaction = false
        interactions_xml = response.response['interactions']['interaction']
      elsif response.response.has_key?('interaction')
        single_interaction = true
        interactions_xml = [response.response['interaction']]
      else
        raise "Invalid response"
      end

      interactions_xml.each do |interaction_element|
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
	
	      interactions << interaction
      end
      
      (single_interaction) ? interactions[0] : interactions
    end

  end
end
