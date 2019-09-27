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

      def apply(value, parent_node: self.parent_node)
        register_node

        self.parent_node = parent_node
        self.schema_errors = { schema_errors_key => [] }
        self.validation_errors = { schema_errors_key => [] }
        self.value = value
        self.value = type[value] unless maybe_criteria_applies?

        self_without_empty_schema_errors
      rescue NxtSchema::Errors::CoercionError => error
        add_schema_error(error.message)
        self_without_empty_schema_errors
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
