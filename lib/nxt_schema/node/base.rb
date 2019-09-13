module NxtSchema
  module Node
    class Base
      def initialize(name:, type:, parent_node:, **options, &block)
        @name = name
        @parent_node = parent_node
        @options = options
        @type = type
        @schema_errors_key = options.fetch(:schema_errors_key, :itself)
        @validations = []
        @level = parent_node ? parent_node.level + 1 : 0
        @all_nodes = parent_node ? (parent_node.all_nodes || []) : []
        @root = parent_node.nil?

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
                    :level,
                    :validation_errors,
                    :all_nodes,
                    :value

      def add_schema_error(error, index = schema_errors_key)
        schema_errors[index] ||= []
        schema_errors[index] << error

        validation_errors[index] ||= []
        validation_errors[index] << error

        # error_namespace = [namespace, index_key].compact.join('.')
        # errors[error_namespace] ||= []
        # errors[error_namespace] << error
      end

      def add_error(error, index = schema_errors_key)
        validation_errors[index] ||= []
        validation_errors[index] << error
      end

      def validate_all_nodes
        sorted_nodes = all_nodes.sort do |node, other_node|
          [node.level, (!node.leaf?).to_s] <=> [other_node.level, (!other_node.leaf?).to_s]
        end

       sorted_nodes.reverse_each(&:apply_validations)
      end

      def apply_validations
        # We don't run validations in case there are schema errors
        # to avoid weird errors

        # First reject empty schema_errors
        schema_errors.reject! { |_, v| v.empty? }
        build_validations

        unless schema_errors[schema_errors_key] && schema_errors[schema_errors_key].any?
          validations.each do |validation|
            validation.call(self, value)
          end
        end

        if self.is_a?(NxtSchema::Node::Array)
          value.each_with_index do |item, index|
            validation_errors[index].reject! { |_, v| v.empty? }
          end
        end

        validation_errors.reject! { |_, v| v.empty? }

        self
      end

      def build_validations
        validations_from_options = Array(options.fetch(:validate, []))
        self.validations = validations_from_options
      end

      def errors_on_self
        schema_errors.errors_on_self
      end

      def schema_errors?
        schema_errors.reject! { |_, v| v.empty? }
        schema_errors.any?
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

      def root?
        @root
      end

      def leaf?
        false
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
