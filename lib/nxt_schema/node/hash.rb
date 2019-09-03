module NxtSchema
  module Node
    class Hash < Node::Base
      def initialize(name, parent_node, options, &block)
        @store = HashNodeStore.new
        @value_store = {}

        super(name, ::Hash, parent_node, options, &block)
      end

      delegate_missing_to :value_store

      def apply(hash)
        raise_coercion_error(hash, type) unless hash.is_a?(type)

        store.each do |key, node|
          ensure_required_key_not_missing(node, hash, key)

          if node.apply(hash[key])
            value_store[key] = hash[key]
          end
        end

      rescue NxtSchema::Errors::RequiredKeyMissingError => error
        add_error(nil, error.message)
      ensure
        self
      end

      private

      def ensure_required_key_not_missing(node, hash, key)
        return if hash.key?(key)
        return if options[:optional]
        # maybe

        raise NxtSchema::Errors::RequiredKeyMissingError.new(node, key, value)
      end
    end
  end
end
