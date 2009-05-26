module Gluepi
  class Response
  end

  class ErrorResponse < Response
    attr_accessor :code, :name, :message
  end

  class AdaptiveBlueResponse < Response
    attr_accessor :response, :timestamp
  end

end


