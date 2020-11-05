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
        # TODO: Test that this raises
        if is_a?(Collection) && !sub_nodes.empty?
          raise ArgumentError, "It's not possible to define multiple nodes within a collection"
        end

        sub_nodes.add(node)
        node
      end

      def each_node(&block)
        sub_nodes.each(&block)
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
