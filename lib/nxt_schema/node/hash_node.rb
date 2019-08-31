module NxtSchema
  module Node
    class HashNode < Node::Base
      def initialize(name, parent_node, options, &block)
        @store = HashNodeStore.new
        @value_store = {}

        super(name, Hash, parent_node, options, &block)
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
