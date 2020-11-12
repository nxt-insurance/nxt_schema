module NxtSchema
  module Application
    class Base
      def initialize(node:, input: MissingInput.new, parent:, context:, error_key:)
        @node = node
        @input = input
        @parent = parent
        @output = nil
        @error_key = error_key
        @context = context || parent&.context
        @applied = false
        @applied_nodes = parent&.applied_nodes || []
        @is_root = parent_node.nil?
        @root = parent_node.nil? ? self : parent_node.root

        resolve_nested_error_key
        initialize_error_stores
      end

      attr_accessor :output, :node, :input
      attr_reader :parent, :context, :error_key, :nested_error_key, :applied, :applied_nodes, :root, :errors

      def call
        raise NotImplementedError, 'Implement this in our sub class'
      end

      delegate :schema_errors,
        :flat_schema_errors,
        :validation_errors,
        :add_schema_error,
        :add_validation_error,
        :merge_schema_errors,
        to: :errors

      delegate_missing_to :node

      def root?
        @is_root
      end

      def valid?
        !errors.any?
      end

      def add_error(error)
        add_validation_error(error)
      end

      def run_validations
        return false unless applied?

        validatations.each do |validation|
          args = [self, input]
          validation.call(*args.take(validation.arity))
        end
      end

      private

      attr_writer :applied, :root

      def coerce_input
        apply_on_evaluators

        if maybe_evaluator_applies?
          self.output = input
        else
          output = input.is_a?(MissingInput) && node.omnipresent? ? input : type[input]
          self.output = output
        end

      rescue Dry::Types::ConstraintError, Dry::Types::CoercionError => error
        add_schema_error(error.message)
      end

      def apply_on_evaluators
        on_evaluators.each { |evaluator| self.input = evaluator.call(input, self, context) }
      end

      def maybe_evaluator_applies?
        @maybe_evaluator_applies ||= maybe_evaluators.inject(false) do |acc, evaluator|
          result = (acc || evaluator.call(input, self, context))
          break true if result

          result
        end
      end

      def resolve_nested_error_key
        parts = []

        if parent
          parts << parent.nested_error_key
        else
          parts << name
        end

        parts << node.name if error_key.is_a?(Integer) && error_key != node.name
        parts << error_key
        parts.compact!
        parts.reject! { |part| part == Application::Errors::DEFAULT_ERROR_KEY }
        @nested_error_key = parts.join('.')
      end

      def register_as_applied
        self.applied = true
        applied_nodes << self
      end

      def initialize_error_stores
        @application_errors = ApplicationErrors.new if root?
        @errors = Errors.new(application)
      end

      def application_errors
        @application_errors ||= root? ? @application_errors : root.application_errors
      end

      def errors
        @errors ||= root.error_store
      end
    end
  end
end
