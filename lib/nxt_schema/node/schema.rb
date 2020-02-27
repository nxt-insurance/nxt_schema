module NxtSchema
  module Node
    class Schema < Node::Base
      def initialize(name:, type: NxtSchema::Types::Strict::Hash, parent_node:, **options, &block)
        @template_store = TemplateStore.new
        super
      end

      def apply(hash, parent_node: self.parent_node, context: nil)
        register_node(context)

        self.parent_node = parent_node
        self.schema_errors = { schema_errors_key => [] }
        self.validation_errors = { schema_errors_key => [] }
        self.value_store = {}
        self.value = hash

        if maybe_criteria_applies?
          self.value_store = hash
        else
          self.value = value_or_default_value

          unless maybe_criteria_applies?
            self.value = type[value]

            # TODO: We should not allow additional keys to be present per default?!
            # TODO: Handle this here
            template_store.each do |key, node|
              if hash.key?(key)
                node.apply(hash[key], parent_node: self, context: context).schema_errors?
                value_store[key] = node.value
                schema_errors[key] = node.schema_errors
                validation_errors[key] = node.validation_errors
              else
                evaluate_optional_option(node, hash, key)
              end
            end

            self.value_store = type[value_store]
            self.value = value_store
          end
        end

        self_without_empty_schema_errors
      rescue Dry::Types::ConstraintError => error
        add_schema_error(error.message)
        self_without_empty_schema_errors
      end

      private

      def evaluate_optional_option(node, hash, key)
        optional_option = node.options[:optional]

        if optional_option.respond_to?(:call)
          # Validator is added to the schema node!
          add_validators(validator(:optional_node, optional_option, key))
        elsif !optional_option
          add_schema_error("Required key :#{key} is missing in #{hash}")
        end
      end
    end
  end
end
