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

      def apply(value, parent_node: self.parent_node, context: nil)
        register_node(context)

        self.parent_node = parent_node
        self.schema_errors = { schema_errors_key => [] }
        self.validation_errors = { schema_errors_key => [] }
        self.value = value

        unless maybe_criteria_applies?
          self.value = value_or_default_value
          self.value = type[value_or_default_value] unless maybe_criteria_applies?
        end

        self_without_empty_schema_errors
      rescue Dry::Types::ConstraintError => error
        add_schema_error(error.message)
        self_without_empty_schema_errors
      end

      private

      def resolve_type(name_or_type)
        return name_or_type if name_or_type.is_a?(Dry::Types::Type)

        default_type_system.const_get(name_or_type.to_s.classify)
      end
    end
  end
end
