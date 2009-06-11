module Gluby
  class AdaptiveBlueError < StandardError
    attr_reader :name, :code, :message

    def initialize(error = nil)
      if not error.nil?
        @name     = error['name']
        @code     = error['code'].to_i
        @message  = error['message']
      end
    end
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

