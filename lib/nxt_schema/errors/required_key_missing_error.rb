module NxtSchema
  module Errors
    class RequiredKeyMissingError < Error
      def initialize(node, hash, key)
        @node = node
        @key = key
        @hash = hash
      end

      attr_reader :key, :node, :hash

      def message
        "Required key :#{key} is missing in node: #{hash}"
      end
    end
  end
end
