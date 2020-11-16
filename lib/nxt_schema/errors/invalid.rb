module NxtSchema
  module Errors
    class Invalid < NxtSchema::Error
      def initialize(node)
        @node = node
        super(build_message)
      end

      attr_reader :node

      def build_message
        node.errors
      end
    end
  end
end
