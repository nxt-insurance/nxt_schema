module NxtSchema
  module Node
    class Schema < Node::Base
      include HasSubNodes

      DEFAULT_TYPE = NxtSchema::Types::Strict::Hash

      def initialize(name:, type: DEFAULT_TYPE, parent_node:, **options, &block)
        super
      end

      def optional(name, node_or_type_of_node, **options, &block)
        node(name, node_or_type_of_node, **options.merge(optional: true), &block)
      end

      def omnipresent(name, node_or_type_of_node, **options, &block)
        node(name, node_or_type_of_node, **options.merge(omnipresent: true), &block)
      end
    end
  end
end
