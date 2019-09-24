module NxtSchema
  module Node
    class Schema < Node::Base
      def initialize(name:, type: NxtSchema::Type::Strict::Hash, parent_node:, **options, &block)
        @template_store = TemplateStore.new
        super
      end

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

          template_store.each do |key, node|
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

          self.value = type[value_store]
          self.value_store = parent_value_store[index_or_name] = value_store
        end

        self_without_empty_schema_errors
      rescue NxtSchema::Errors::CoercionError => error
        add_schema_error(error.message)
        self_without_empty_schema_errors
      end
    end
  end
end
