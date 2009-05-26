module Gluepi
  class AdaptiveBlueError < StandardError
  end

  class NotAuthenticated < AdaptiveBlueError; end
  class MissingParameter < AdaptiveBlueError; end
end

