module NxtSchema
  module Nodes
    class ArrayNode < Node
      def initialize(name, parent_node, options, &block)
        @name = name
        @parent_node = parent_node
        @options = options
        @type = options.fetch(:type)
        @store = []
        options.merge!(type: Array)

        block.call(self) if block_given?
      end

      delegate_missing_to :store
    end
  end
end
