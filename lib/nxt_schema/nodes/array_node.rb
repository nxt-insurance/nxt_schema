module NxtSchema
  module Nodes
    class ArrayNode < Node
      def initialize(name, parent_node, options, &block)
        @store = []
        options.merge!(type: Array)

        super
      end

      delegate_missing_to :store

      def validate(target)
        target.each do |item|
          next if store.any? { |node| node.validate(item) }
          add_error(item, "Did not match any node in #{store}")
        end

        self
      end
    end
  end
end
