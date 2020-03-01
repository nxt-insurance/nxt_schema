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

      def apply(input, parent_node: self.parent_node, context: nil)
        self.input = input
        register_node(context)

        self.parent_node = parent_node
        self.schema_errors = { schema_errors_key => [] }
        self.validation_errors = { schema_errors_key => [] }

        if maybe_criteria_applies?(input)
          self.value = input
        else
          self.value = value_or_default_value(input)
          self.value = type[value] unless maybe_criteria_applies?(value)
        end

        self_without_empty_schema_errors
      rescue Dry::Types::ConstraintError, Dry::Types::CoercionError => error
        add_schema_error(error.message)
        self_without_empty_schema_errors
      ensure
        mark_as_applied
      end

      private

      def resolve_type(name_or_type)
        root.send(:type_resolver).resolve(type_system, name_or_type)
      end
    end
  end
end
