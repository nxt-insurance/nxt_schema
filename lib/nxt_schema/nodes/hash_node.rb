module NxtSchema
  module Nodes
    class HashNode < Node
      def initialize(name, parent_node, options, &block)
        @store = HashNodeStore.new
        options.merge!(type: Hash)

        super
      end

      delegate_missing_to :store
    end
  end
end
