module NxtSchema
  module Node
    class Schema < Node::Base
      def initialize(name:, type: NxtSchema::Type::Strict::Hash, parent_node:, **options, &block)
        @template_store = TemplateStore.new
        super
      end

      def apply(hash, parent_node: parent_node, index_or_name: name)
        self.parent_node = parent_node
        self.schema_errors = { schema_errors_key => [] }
        self.validation_errors = { schema_errors_key => [] }
        self.value_store = {}
        self.value = hash
        register_node

        if maybe_criteria_applies?(hash)
          self.value_store = hash
          self.value = hash
        else
          hash = type[hash]

          # TODO: Handle additional keys here!
          template_store.each do |key, node|
            if hash.key?(key)

              node.apply(
                hash[key],
                parent_node: self
              ).schema_errors?

              value_store[key] = node.value
              # TODO: Assemble error after applying node
              schema_errors[key] = node.schema_errors
              validation_errors[key] = node.validation_errors

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

          self.value_store = type[value_store]
          self.value = value_store
        end

        self_without_empty_schema_errors
      rescue NxtSchema::Errors::CoercionError => error
        add_schema_error(error.message)
        self_without_empty_schema_errors
      end
    end
  end
end
