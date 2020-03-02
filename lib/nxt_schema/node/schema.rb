module NxtSchema
  module Node
    class Schema < Node::Base
      def initialize(name:, type: NxtSchema::Types::Strict::Hash, parent_node:, **options, &block)
        @template_store = TemplateStore.new
        super
      end

      def apply(input, parent_node: self.parent_node, context: nil)
        self.input = input
        register_node(context)

        self.parent_node = parent_node
        self.schema_errors = { schema_errors_key => [] }
        self.validation_errors = { schema_errors_key => [] }
        self.value_store = {}
        self.value = transform_keys(input)

        if maybe_criteria_applies?(value)
          self.value_store = value
        else
          self.value = value_or_default_value(value)

          unless maybe_criteria_applies?(value)
            self.value = type[value]

            # TODO: We should not allow additional keys to be present per default?!
            # TODO: Handle this here
            template_store.each do |key, node|
              if node.presence? || input.key?(key)
                node.apply(input[key], parent_node: self, context: context).schema_errors?
                value_store[key] = node.value
                schema_errors[key] = node.schema_errors
                validation_errors[key] = node.validation_errors
              else
                evaluate_optional_option(node, input, key)
              end
            end

            self.value_store = type[value_store]
            self.value = value_store
          end
        end

        self_without_empty_schema_errors
      rescue Dry::Types::ConstraintError, Dry::Types::CoercionError => error
        add_schema_error(error.message)
        self_without_empty_schema_errors
      ensure
        mark_as_applied
      end

      def optional(name, type, **options, &block)
        raise_invalid_options_error if options[:presence]

        node(name, type, options.merge(optional: true), &block)
      end

      def present(name, type, **options, &block)
        raise_invalid_options_error if options[:optional]

        node(name, type, options.merge(presence: true), &block)
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

      def transform_keys(hash)
        return hash unless key_transformer && hash.respond_to?(:transform_keys!)

        hash.transform_keys! { |key| Callable.new(key_transformer).bind(key).call(key) }
      end

      def key_transformer
        @key_transformer ||= root.options.fetch(:transform_keys) { false }
      end

      def raise_invalid_options_error
        raise InvalidOptionsError, 'Options :presence and :optional exclude each other'
      end
    end
  end
end
