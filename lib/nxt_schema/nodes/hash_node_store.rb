module NxtSchema
  module Nodes
    class HashNodeStore < Hash
      def add(node)
        self[node.name] = node
      end
    end
  end
end
