module Gluestick
  class AdaptiveBlueResponse

    # This is the class that wraps the XML response from the API call
    # returned from the Glue API

    attr_accessor :response, :timestamp

    # Takes the Glue API from +Gluestick::Response+ response and wraps it in
    # an object.
    def initialize(response)
      raise ArgumentError if response.kind_of?(Hash)

      response["adaptiveblue"].each_pair do |k,v|
        unless self.respond_to?(k.to_sym)
          self.class.class_eval do
            attr_reader k
          end
        end
        instance_variable_set("@#{k.to_s}", v)
      end
    end
  end

end


