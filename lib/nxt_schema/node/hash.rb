module NxtSchema
  module Node
    class Hash < Node::Base
      def initialize(name:, parent_node:, **options, &block)
        @store = HashNodeStore.new

        super(name: name, type: NxtSchema::Type::Strict::Hash, parent_node: parent_node, **options, &block)
      end

      def dup
        result = super
        result.store = store.deep_dup
        result.options = options.deep_dup
        result
      end

      delegate_missing_to :value_store

      def apply(hash, parent_node: parent_node, parent_schema_errors: {}, parent_validation_errors: {}, parent_value_store: {}, index_or_name: name)
        self.parent_node = parent_node
        self.schema_errors = parent_schema_errors[index_or_name] ||= { schema_errors_key => [] }
        self.validation_errors = parent_validation_errors[index_or_name] ||= { schema_errors_key => [] }
        self.value_store = parent_value_store[index_or_name] ||= {}
        register_node

        if maybe_criteria_applies?(hash)
          self.value_store = parent_value_store[index_or_name] = hash
          self.value = hash
        else
          hash = type[hash]
          self.value = hash

          store.each do |key, node|
            if hash.key?(key)

              node.apply(
                hash[key],
                parent_node: self,
                parent_schema_errors: schema_errors,
                parent_validation_errors: validation_errors,
                parent_value_store: value_store
              ).schema_errors?

            else
              # TODO: Implement proper optional hash nodes
              if node.options[:optional].respond_to?(:call)
                add_validators(OptionalNodeValidator.new(node.options[:optional]))
                elsif node.options[:optional]
                else
                add_schema_error("Required key :#{key} is missing in #{hash}")
              end
            end
          end
        end

        self_without_empty_schema_errors
      rescue NxtSchema::Errors::CoercionError => error
        add_schema_error(error.message)
        self_without_empty_schema_errors
      end
    end
  end
end
