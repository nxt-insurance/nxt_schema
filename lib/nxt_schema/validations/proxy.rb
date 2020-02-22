module NxtSchema
  module Validations
    class Proxy
      def initialize(node)
        @node = node
        @validators = []
      end

      def validate(&block)
        block.call
      end

      def validator(key, *args)
        node.validator(key, *args).call(node, node.value)
      end
    end
  end
end