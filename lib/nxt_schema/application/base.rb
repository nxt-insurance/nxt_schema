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
        @is_root = parent.nil?
        @root = parent.nil? ? self : parent.root
        @errors = ErrorStore.new(self)
        @locale = options.fetch(:locale) { parent&.locale || 'en' }.to_s

        resolve_error_key(error_key)
      end

      attr_accessor :output, :node, :input
      attr_reader :parent, :context, :error_key, :nested_error_key, :applied, :applied_nodes, :root, :errors, :locale

      def call
        raise NotImplementedError, 'Implement this in our sub class'
      end

      delegate_missing_to :node

      def root?
        @is_root
      end

      def valid?
        errors.empty?
      end

      def add_error(error)
        errors.add_validation_error(message: error)
      end

      def add_schema_error(error)
        errors.add_schema_error(message: error)
      end

      def merge_errors(application)
        errors.merge_errors(application)
      end

      def run_validations
        return false unless applied?

        validations.each do |validation|
          args = [self, input]
          validation.call(*args.take(validation.arity))
        end
      end

      def up(levels = 1)
        0.upto(levels - 1).inject(self) do |acc, _|
          parent = acc.send(:parent)
          break acc unless parent

          parent
        end
      end

      private

      attr_writer :applied, :root

      def coerce_input
        output = input.is_a?(MissingInput) && node.omnipresent? ? input : type[input]
        self.output = output

      rescue Dry::Types::ConstraintError, Dry::Types::CoercionError => error
        add_schema_error(error.message)
      end

      def apply_on_evaluators
        on_evaluators.each { |evaluator| self.input = evaluator.call(input, self, context) }
      end

      def maybe_evaluator_applies?
        @maybe_evaluator_applies ||= maybe_evaluators.inject(false) do |acc, evaluator|
          result = (acc || evaluator.call(input, self, context))

          if result
            self.output = input
            break true
          else
            false
          end
        end
      end

      def register_as_applied_when_valid
        return unless valid?

        self.applied = true
        applied_nodes << self
      end

      def resolve_error_key(key)
        parts = [parent&.error_key].compact
        parts << (key.present? ? "#{node.name}[#{key}]" : node.name)
        @error_key = parts.join('.')
      end

      def applied?
        @applied
      end
    end
  end
end
