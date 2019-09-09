module NxtSchema
  module Node
    class Hash < Node::Base
      include NxtSchema::Node::Collection

      def initialize(name, parent_node, options, &block)
        @store = HashNodeStore.new

        super(name, NxtSchema::Type::Strict::Hash, parent_node, options, &block)
      end

      delegate_missing_to :value_store

      def apply(hash, parent_errors = {}, parent_value_store = {}, index_or_name = name)
        self.node_errors = parent_errors[name] ||= { node_errors_key => [] }
        self.value_store = parent_value_store[index_or_name] ||= {}

        hash = type[hash]
        store.each do |key, node|
          if required_key_missing?(hash, key)
            # node.add_error("Required key :#{key} is missing in #{hash}")
            # node_errors[node_errors_key] << "Required key :#{key} is missing in #{hash}"
            add_error("Required key :#{key} is missing in #{hash}")
          else
            node.apply(hash[key], node_errors, value_store).valid?
          end
        end

        self_without_empty_node_errors
      rescue NxtSchema::Errors::CoercionError => error
        add_error(error.message)
        self_without_empty_node_errors
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
