module NxtSchema
  module Node
    module HasSubNodes
      def node(name, node_or_type_of_node, **options, &block)
        node = case node_or_type_of_node.to_s.downcase.to_sym
        when :array
          build_array_node(name, **options, &block)
        else
          if node_or_type_of_node.is_a?(NxtSchema::Node::Base)
            # node = type_or_node.clone
            # node.options.merge!(options)
            # node.name = name
            # node.parent = self
            # node
          else
            # TODO: We should check whether the type is registered
            build_leaf_node(name, node_or_type_of_node, **options, &block)
          end
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

      private

      def build_leaf_node(name, type, **options, &block)
        NxtSchema::Node::Leaf.new(name: name, value_type: type, parent_node: self, **options, &block)
      end

      def build_array_node(name, **options, &block)
        NxtSchema::Node::Array.new(name: name, value_type: ::Array, parent_node: self, **options, &block)
      end
    end
  end
end
