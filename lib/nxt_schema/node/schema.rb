module NxtSchema
  module Node
    class Schema < Node::Base
      def initialize(name:, type: NxtSchema::Types::Strict::Hash, parent_node:, **options, &block)
        @template_store = TemplateStore.new
        super
      end

      def apply(hash, parent_node: self.parent_node)
        register_node

        self.parent_node = parent_node
        self.schema_errors = { schema_errors_key => [] }
        self.validation_errors = { schema_errors_key => [] }
        self.value_store = {}
        self.value = hash

        if maybe_criteria_applies?
          self.value_store = hash
          self.value = hash
        else
          self.value = type[hash]

          # TODO: Handle additional keys here!
          template_store.each do |key, node|
            if hash.key?(key)

              node.apply(hash[key], parent_node: self).schema_errors?

              value_store[key] = node.value
              schema_errors[key] = node.schema_errors
              validation_errors[key] = node.validation_errors

            else
              # TODO: Can we move this to the node?
              optional_option = node.options[:optional]

              if optional_option.respond_to?(:call)
                # Validator is added to the schema node!
                add_validators(validator(:optional_node, optional_option, key))
              elsif !optional_option
                add_schema_error("Required key :#{key} is missing in #{hash}")
              end
            end
          end

          self.value_store = type[value_store]
          self.value = value_store
        end

        self_without_empty_schema_errors
      rescue Dry::Types::ConstraintError => error
        add_schema_error(error.message)
        self_without_empty_schema_errors
      end
    end
  end
end
