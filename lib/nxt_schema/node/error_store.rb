module NxtSchema
  module Node
    class ErrorStore < ::Hash
      def initialize(node)
        super()
        @node = node
      end

      attr_reader :node

      def add_schema_error(message:)
        add_error(
          node,
          NxtSchema::Node::Errors::SchemaError.new(
            node: node,
            message: message
          )
        )
      end

      def add_validation_error(message:)
        add_error(
          node,
          NxtSchema::Node::Errors::ValidationError.new(
            node: node,
            message: message
          )
        )
      end

      def merge_errors(node)
        merge!(node.errors)
      end

      def add_error(node, error)
        self[node.error_key] ||= []
        self[node.error_key] << error
      end
    end
  end
end
