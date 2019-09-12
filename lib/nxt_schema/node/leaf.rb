module NxtSchema
  module Node
    class Leaf < Node::Base
      def initialize(name:, type: type, parent_node: parent_node, **options, &block)
        super
        @type = resolve_type(type)
      end

      def leaf?
        true
      end

      def apply(value, parent_schema_errors: {}, parent_value_store: {}, index_or_name: name)
        self.schema_errors = parent_schema_errors[name] ||= { schema_errors_key => [] }

        unless maybe_criteria_applies?(value)
          value = type[value]

          validations.each do |validation|
            validation_args = [self, value]
            validation.call(*validation_args.take(validation.arity))
          end
        end

        parent_value_store[index_or_name] = value

        self_without_empty_schema_errors
      rescue NxtSchema::Errors::CoercionError => error
        add_error(error.message)
        self_without_empty_schema_errors
      end

      def add_error(error)
        schema_errors[schema_errors_key] << error

        # error_namespace = [namespace, index_key].compact.join('.')
        # errors[error_namespace] ||= []
        # errors[error_namespace] << error
      end

      def valid?
        schema_errors.empty?
      end

      private

      def resolve_type(name)
        Type.resolve(name)
      end
    end
  end
end
