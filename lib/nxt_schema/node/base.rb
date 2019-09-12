module NxtSchema
  module Node
    class Base
      def initialize(name:, type:, parent_node:, **options, &block)
        @name = name
        @parent_node = parent_node
        @options = options
        @type = type
        @schema_errors_key = options.fetch(:schema_errors_key, :itself)
        @validations = Array(options.fetch(:validate, []))
        @level = parent_node ? parent_node.level + 1 : 0

        # Note that it is not possible to use present? on an instance of NxtSchema::Schema since it inherits from Hash
        block.call(self) if block_given?
      end

      attr_accessor :name,
                    :parent_node,
                    :options,
                    :type,
                    :schema_errors,
                    :namespace,
                    :errors,
                    :validations,
                    :schema_errors_key,
                    :level

      def add_error(error, index = schema_errors_key)
        schema_errors[index] ||= []
        schema_errors[index] << error

        # error_namespace = [namespace, index_key].compact.join('.')
        # errors[error_namespace] ||= []
        # errors[error_namespace] << error
      end

      def errors_on_self
        schema_errors.errors_on_self
      end

      def valid?
        schema_errors.reject! { |_, v| v.empty? }
        schema_errors.empty?
      end

      def optional?
        optional_evaluator = options[:optional]

        if optional_evaluator.respond_to?(:call)
          optional_evaluator_args = [self]
          optional_evaluator.call(*optional_evaluator_args.take(optional_evaluator.arity))
        else
          optional_evaluator
        end
      end

      private

      def maybe_criteria_applies?(value)
        return unless options.key?(:maybe)
        MaybeEvaluator.new(options.fetch(:maybe), value).call
      end

      def self_without_empty_schema_errors
        schema_errors.reject! { |_, v| v.empty? }
        self
      end

      def raise_coercion_error(value, type)
        raise NxtSchema::Errors::CoercionError.new(value, type)
      end
    end
  end
end
