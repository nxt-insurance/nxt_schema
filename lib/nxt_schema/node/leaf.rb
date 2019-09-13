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

      def apply(value, parent_schema_errors: {}, parent_validation_errors: {}, parent_value_store: {}, index_or_name: name)
        self.schema_errors = parent_schema_errors[name] ||= { schema_errors_key => [] }
        self.validation_errors = parent_validation_errors[name] ||= { schema_errors_key => [] }
        all_nodes << self
        self.value = value

        unless maybe_criteria_applies?(value)
          value = type[value]
          self.value = value

          # TODO: Setup validations here
          # Array(options.fetch(:validate, [])).each do |validation|
          #   validation_args = [self, value]
          #   validation.call(*validation_args.take(validation.arity))
          # end
        end

        parent_value_store[index_or_name] = value

        self_without_empty_schema_errors
      rescue NxtSchema::Errors::CoercionError => error
        add_schema_error(error.message)
        self_without_empty_schema_errors
      end

      def add_schema_error(error)
        schema_errors[schema_errors_key] << error
        validation_errors[schema_errors_key] << error

        # error_namespace = [namespace, index_key].compact.join('.')
        # errors[error_namespace] ||= []
        # errors[error_namespace] << error
      end

      def add_error(error)
        validation_errors[schema_errors_key] << error

        # error_namespace = [namespace, index_key].compact.join('.')
        # errors[error_namespace] ||= []
        # errors[error_namespace] << error
      end

      def schema_errors?
        schema_errors.any?
      end

      def leaf?
        true
      end

      private

      def resolve_type(name)
        Type.resolve(name)
      end
    end
  end
end
