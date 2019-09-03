module NxtSchema
  module Errors
    class RequiredKeyMissingError < Error
      def initialize(node, key, value)
        @node = node
        @key = key
        @value = value
      end

      attr_reader :key, :node, :value

      def message
        "Required key :#{key} is missing in node: #{value}"
      end
    end
  end
end
