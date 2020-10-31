module NxtSchema
  module Node
    class SubNodes < ::Hash
      def add(node)
        node_name = node.name
        ensure_node_name_free(node_name)
        self[node_name] = node
      end

      def ensure_node_name_free(name)
        return unless key?(name)

        raise KeyError, "Node with name '#{name}' already exists! Node names must be unique!"
      end
    end
  end
end