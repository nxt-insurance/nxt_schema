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

      def apply(hash, parent_errors = {})
        self.node_errors = parent_errors[name] ||= { node_errors_key => [] }
        hash = type[hash]

        store.each do |key, node|
          if required_key_missing?(hash, key)
            # node.add_error("Required key :#{key} is missing in #{hash}")
            node_errors[node_errors_key] << "Required key :#{key} is missing in #{hash}"
          else
            if node.apply(hash[key], node_errors).valid?
              value_store[key] = hash[key]
            end
          end
        end
      rescue NxtSchema::Errors::CoercionError => error
        node_errors[node_errors_key] << error.message
      ensure
        node_errors.reject! { |_, v| v.empty? }
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
