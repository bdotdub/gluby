module Gluestick
  class AdaptiveBlueError < StandardError
  end

  class NotAuthenticated < AdaptiveBlueError; end
  class MissingParameter < AdaptiveBlueError; end
  class PermissionError < AdaptiveBlueError; end
  class InvalidURL < AdaptiveBlueError; end
  class InvalidObject < AdaptiveBlueError; end
  class InvalidInteraction < AdaptiveBlueError; end
  class InvalidUser < AdaptiveBlueError; end
  class InternalServerError < AdaptiveBlueError; end
end

