module NxtSchema
  module Node
    class Hash < Node::Base
      include NxtSchema::Node::Collection

      def initialize(name, parent_node, options, &block)
        @store = HashNodeStore.new
        @value_store = {}

        super(name, NxtSchema::Type::Strict::Hash, parent_node, options, &block)
      end

      delegate_missing_to :value_store

      def apply(hash, index = nil)
        hash = type[hash]

        store.each do |key, node|
          if required_key_missing?(hash, key)
            add_error("Required key :#{key} is missing in #{hash}", index)
          else
            if node.apply(hash[key])
              value_store[key] = hash[key]
            end
          end
        end
      ensure
        return self
      end

      private

      def required_key_missing?(hash, key)
        return if hash.key?(key)
        return if options[:optional]
        # maybe
        true
      end
    end
  end
end
