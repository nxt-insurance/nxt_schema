module NxtSchema
  module Nodes
    class ArrayNode < Node
      def initialize(name, parent_node, options, &block)
        @store = []
        options.merge!(type: Array)

        super
      end
    end
  end
end
