module NxtSchema
  module Nodes
    class HashNode < Node
      def initialize(name, parent_node, options, &block)
        @store = HashNodeStore.new
        options.merge!(type: Hash)

        super
      end
    end
  end
end
