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

      def any_of

      end

      def node(name, node_or_type_of_node, **options, &block)
        node = if node_or_type_of_node.is_a?(NxtSchema::Node::Base)
          # node = type_or_node.clone
          # node.options.merge!(options)
          # node.name = name
          # node.parent = self
          # node
        else
          NxtSchema::Node::Leaf.new(name: name, type: node_or_type_of_node, parent_node: self, **options, &block)
        end

        add_sub_node(node)
      end

      alias required node

      def add_sub_node(node)
        sub_nodes.add(node)
        node
      end

      def each_node(&block)
        sub_nodes.each(&block)
      end

      def sub_nodes
        @sub_nodes ||= Node::SubNodes.new
      end
    end
  end
end
