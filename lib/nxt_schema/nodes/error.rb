module NxtSchema
  module Nodes
    class Error
      def initialize(path, value, error_message)
        @path = path
        @value = value
        @error_message = error_message
      end

      def to_s

      end
    end
  end
end
