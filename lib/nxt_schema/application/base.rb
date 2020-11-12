module NxtSchema
  module Application
    class Base
      def initialize(node:, input: MissingInput.new, parent:, context:, error_key:)
        @node = node
        @input = input
        @parent = parent
        @output = nil
        @error_key = error_key
        @errors = Errors.new(application: self, node: node)
        @context = context || parent&.context
        @applied = false
        @applied_nodes = parent&.applied_nodes || []

        resolve_nested_error_key
      end

      attr_accessor :output, :node, :input
      attr_reader :parent, :errors, :context, :error_key, :nested_error_key, :applied, :applied_nodes

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

      def valid?
        !errors.any?
      end

      # Adds a validation error
      def add_error(*args)

      end

      private

      attr_writer :applied

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
    end
  end
end
