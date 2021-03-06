module NxtSchema
  module Template
    module HasSubNodes
      def collection(name, type = NxtSchema::Template::Collection::DEFAULT_TYPE, **options, &block)
        node = NxtSchema::Template::Collection.new(
          name: name,
          type: type,
          parent_node: self,
          **options,
          &block
        )

        add_sub_node(node)
      end

      alias nodes collection

      def schema(name, type = NxtSchema::Template::Schema::DEFAULT_TYPE, **options, &block)
        node = NxtSchema::Template::Schema.new(
          name: name,
          type: type,
          parent_node: self,
          **options,
          &block
        )

        add_sub_node(node)
      end

      def any_of(name, **options, &block)
        node = NxtSchema::Template::AnyOf.new(
          name: name,
          parent_node: self,
          **options,
          &block
        )

        add_sub_node(node)
      end

      def node(name, node_or_type_of_node, **options, &block)
        node = if node_or_type_of_node.is_a?(NxtSchema::Template::Base)
          raise ArgumentError, "Can't provide a block along with a node" if block.present?

          node_or_type_of_node.class.new(
            name: name,
            type: node_or_type_of_node.type,
            parent_node: self,
            **node_or_type_of_node.options.merge(options),
            &node_or_type_of_node.configuration
          )
        else
          NxtSchema::Template::Leaf.new(
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
        @sub_nodes ||= Template::SubNodes.new
      end

      def [](key)
        sub_nodes[key]
      end

      def ensure_sub_nodes_present
        return if sub_nodes.any?

        raise NxtSchema::Errors::InvalidOptions, "#{self.class.name} must have sub nodes"
      end
    end
  end
end
