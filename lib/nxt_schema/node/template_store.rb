module NxtSchema
  module Node
    class TemplateStore < ::Hash
      def push(node)
        node_name = node.name
        raise_key_error(node_name) if key?(node_name)
        self[node_name] = node
      end

      def raise_key_error(key)
        raise KeyError, "Node with name '#{key}' already registered! Node names must be unique!"
      end
    end
  end
end
