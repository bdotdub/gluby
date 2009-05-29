module Gluestick
  module LazyLoader
    def lazy_load(properties, method)
      properties.each do |property|
        define_method(property) do
          if not instance_variables.include?("@#{property}")
            send method
          end
          instance_variable_get("@#{property}")
        end
      end
    end
  end
end
