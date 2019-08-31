module NxtSchema
  module Nodes
    class HashNode < Node
      def initialize(name, parent_node, options, &block)
        @store = HashNodeStore.new
        @value_store = {}
        options.merge!(type: Hash)

        super
      end

      delegate_missing_to :value_store

      def validate(target)
        store.each do |key, node|
          if node.validate(target[key])
            value_store[key] = target[key]
          end
        end

        self
      end
    end
  end
end
