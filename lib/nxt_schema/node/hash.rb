module NxtSchema
  module Node
    class Hash < Node::Base
      def initialize(name, parent_node, options, &block)
        @store = HashNodeStore.new
        @value_store = {}

        super(name, ::Hash, parent_node, options, &block)
      end

      delegate_missing_to :value_store

      def validate(hash)
        raise_coercion_error(hash, type) unless hash.is_a?(type)

        store.each do |key, node|
          check_key_requirements(hash, key)

          if node.validate(hash[key])
            value_store[key] = hash[key]
          end
        end

      rescue NxtSchema::Errors::RequiredKeyMissingError => error
        add_error(nil, error.message)
      ensure
        self
      end

      private

      def check_key_requirements(hash, key)
        return unless parent_node
        return if hash.key?(key)
        return if options[:optional]
        # maybe

        raise NxtSchema::Errors::RequiredKeyMissingError.new(hash, key)
      end
    end
  end
end
