module NxtSchema
  module Application
    class Base
      def initialize(node:, input: MissingInput.new, parent:, context:, error_key:)
        @node = node
        @input = input
        @parent = parent
        @output = nil
        @context = context || parent&.context
        @applied = false
        @applied_nodes = parent&.applied_nodes || []
        @is_root = parent.nil?
        @root = parent.nil? ? self : parent.root

        resolve_error_key(error_key)
        initialize_error_stores
      end

      attr_accessor :output, :node, :input
      attr_reader :parent, :context, :error_key, :applied, :applied_nodes, :root, :local_errors

      def call
        raise NotImplementedError, 'Implement this in our sub class'
      end

      delegate_missing_to :node

      def root?
        @is_root
      end

      def valid?
        !errors.any?
      end

      def no_local_errors?
        !local_errors?
      end

      def local_errors?
        local_errors.any?
      end

      def add_error(error)
        local_errors.add_validation_error(error)
        errors.add_validation_error(self, error)
      end

      def add_schema_error(error)
        local_errors.add_schema_error(error)
        errors.add_schema_error(self, error)
      end

      def run_validations
        return false unless applied?

        validatations.each do |validation|
          args = [self, input]
          validation.call(*args.take(validation.arity))
        end
      end

      def errors
        @errors ||= root? ? @errors : root.errors
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

      def register_if_applied
        return if local_errors?

        self.applied = true
        applied_nodes << self
      end

      def initialize_error_stores
        @errors = GlobalErrors.new if root?
        @local_errors = LocalErrors.new(self)
      end

      def resolve_error_key(key)
        parts = [parent&.error_key].compact
        parts << (key.present? ? "#{node.name}[#{key}]" : node.name)
        @error_key = parts.join('.')
      end
    end
  end
end
