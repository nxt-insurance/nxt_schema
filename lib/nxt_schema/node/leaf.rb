module NxtSchema
  module Node
    class Leaf < Node::Base
      def initialize(name:, type:, parent_node:, **options, &block)
        super
        @type = resolve_type(type)
      end

      def leaf?
        true
      end

      def apply(value, parent_node: parent_node, parent_schema_errors: {}, parent_validation_errors: {}, parent_value_store: {}, index_or_name: name)
        self.parent_node = parent_node
        self.schema_errors = parent_schema_errors[index_or_name] ||= { schema_errors_key => [] }
        self.validation_errors = parent_validation_errors[index_or_name] ||= { schema_errors_key => [] }

        register_node
        self.value = value

        if !maybe_criteria_applies?(value)
          value = type[value]
          self.value = value
        elsif options[:optional].respond_to?(:call)
          # TODO: Implement proper optional leafs
          # Be aware that the arg yielded to validators should be the same in both cases ... ?!
          add_validators(OptionalNodeValidator.new(options[:optional]))
        end

        # parent_value_store[index_or_name] = value

        self_without_empty_schema_errors
      rescue NxtSchema::Errors::CoercionError => error
        add_schema_error(error.message)
        self_without_empty_schema_errors
      end

      def add_schema_error(error)
        schema_errors[schema_errors_key] << error
        validation_errors[schema_errors_key] << error
      end

      def add_error(error)
        validation_errors[schema_errors_key] << error
      end

      def schema_errors?
        schema_errors.any?
      end

      def leaf?
        true
      end

      private

      def resolve_type(name)
        default_type_system.resolve(name)
      rescue KeyError
        NxtSchema::Type.resolve(name)
      rescue KeyError
        raise KeyError, "Could not resolve type in neither #{default_type_system} nor in #{NxtSchema::Type}"
      end
    end
  end
end
