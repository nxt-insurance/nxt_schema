module NxtSchema
  module Application
    class Base
      def initialize(node:, input:, parent:)
        @node = node
        @input = input
        @parent = parent
        @output = nil
      end

      attr_accessor :output, :node, :input

      def call
        raise NotImplementedError, 'Implement this in our sub class'
      end

      delegate_missing_to :node

      private

      def apply_type
        send(node.value_type, input)
      end
    end
  end
end
