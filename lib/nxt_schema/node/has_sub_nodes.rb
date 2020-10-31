module NxtSchema
  module Node
    module HasSubNodes
      def array(name, value_type = NxtSchema::Node::Array::DEFAULT_TYPE, **options, &block)
        node = NxtSchema::Node::Array.new(name: name, value_type: value_type, parent_node: self, **options, &block)
        add_sub_node(node)
      end

      def hash(name, value_type = NxtSchema::Node::Hash::DEFAULT_TYPE, **options, &block)
        node = NxtSchema::Node::Hash.new(name: name, value_type: value_type, parent_node: self, **options, &block)
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
          NxtSchema::Node::Leaf.new(name: name, value_type: node_or_type_of_node, parent_node: self, **options, &block)
        end

        add_sub_node(node)
      end

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

      def any_of(&block)
        @all_of = false
        @any_of = true

        configure(&block)
        self
      end

      def all_of(&block)
        @any_of = false
        @all_of = true

        configure(&block)
        self
      end

      def sub_nodes_evaluation?(value)
        value == (@all_of ? :all : :any)
      end
    end
  end
end