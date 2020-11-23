module NxtSchema
  module Node
    class Collection < Node::Base
      include HasSubNodes

      DEFAULT_TYPE = NxtSchema::Types::Strict::Array

      def initialize(name:, type: DEFAULT_TYPE, parent_node:, **options, &block)
        super
        ensure_sub_nodes_present
      end

      private

      def add_sub_node(node)
        # TODO: Spec that this raises
        raise ArgumentError, "It's not possible to define multiple nodes within a collection" unless sub_nodes.empty?

        super
      end
    end
  end
end
