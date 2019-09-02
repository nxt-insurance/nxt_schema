module NxtSchema
  module Errors
    class RequiredKeyMissingError < Error
      def initialize(node, key)
        @node = node
        @key = key
      end

      attr_reader :key, :node

      def message
        "Required key :#{key} is missing in node: #{node}"
      end
    end
  end
end
