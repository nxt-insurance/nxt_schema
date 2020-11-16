module NxtSchema
  module Node
    module HasSubNodes
      def collection(name, type = NxtSchema::Node::Collection::DEFAULT_TYPE, **options, &block)
        node = NxtSchema::Node::Collection.new(
          name: name,
          type: type,
          parent_node: self,
          **options,
          &block
        )

        add_sub_node(node)
      end

      alias nodes collection

      def schema(name, type = NxtSchema::Node::Schema::DEFAULT_TYPE, **options, &block)
        node = NxtSchema::Node::Schema.new(
          name: name,
          type: type,
          parent_node: self,
          **options,
          &block
        )

        add_sub_node(node)
      end

      def any_of(name, **options, &block)
        node = NxtSchema::Node::AnyOf.new(
          name: name,
          parent_node: self,
          **options,
          &block
        )

        add_sub_node(node)
      end

      def node(name, node_or_type_of_node, **options, &block)
        node = if node_or_type_of_node.is_a?(NxtSchema::Node::Base)
          raise ArgumentError, "Can't provide a block along with a node" if block.present?

          node_or_type_of_node.class.new(
            name: name,
            type: node_or_type_of_node.type,
            parent_node: self,
            **node_or_type_of_node.options.merge(options), # Does this make sense to merge options here?
            &node_or_type_of_node.configuration
          )
        else
          NxtSchema::Node::Leaf.new(
            name: name,
            type: node_or_type_of_node,
            parent_node: self,
            **options,
            &block
          )
        end

        add_sub_node(node)
      end

      alias required node

      def add_sub_node(node)
        sub_nodes.add(node)
        node
      end

      def sub_nodes
        @sub_nodes ||= Node::SubNodes.new
      end

      def [](key)
        sub_nodes[key]
      end
    end
  end
end
