module NxtSchema
  module Node
    class HashNodeStore < ::Hash
      def push(node)
        self[node.name] = node
      end
    end
  end
end
