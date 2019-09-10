module NxtSchema
  module Node
    class Hash < Node::Base
      include NxtSchema::Node::Collection

      def initialize(name, parent_node, options, &block)
        @store = HashNodeStore.new

        super(name, NxtSchema::Type::Strict::Hash, parent_node, options, &block)
      end

      delegate_missing_to :value_store

      def apply(hash, parent_errors: {}, parent_value_store: {}, index_or_name: name)
        self.node_errors = parent_errors[name] ||= { node_errors_key => [] }
        self.value_store = parent_value_store[index_or_name] ||= {}

        if maybe_criteria_applies?(hash)
          self.value_store = parent_value_store[index_or_name] = hash
        else
          hash = type[hash]

          store.each do |key, node|
            if hash.key?(key)
              node.apply(hash[key], parent_errors: node_errors, parent_value_store: value_store).valid?
            else
              unless node.options[:optional]
                add_error("Required key :#{key} is missing in #{hash}")
              end
            end
          end
        end

        self_without_empty_node_errors
      rescue NxtSchema::Errors::CoercionError => error
        add_error(error.message)
        self_without_empty_node_errors
      end
    end
  end
end
