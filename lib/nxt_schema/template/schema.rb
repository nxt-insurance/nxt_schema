module NxtSchema
  module Template
    class Schema < Template::Base
      include HasSubNodes

      DEFAULT_TYPE = NxtSchema::Types::Strict::Hash

      def initialize(name:, type: DEFAULT_TYPE, parent_node:, **options, &block)
        super
        ensure_sub_nodes_present
      end

      def optional(name, node_or_type_of_node: Undefined.new, **options, &block)
        node(name, node_or_type_of_node: node_or_type_of_node, **options.merge(optional: true), &block)
      end

      def omnipresent(name, node_or_type_of_node: Undefined.new, **options, &block)
        node(name, node_or_type_of_node: node_or_type_of_node, **options.merge(omnipresent: true), &block)
      end
    end
  end
end
