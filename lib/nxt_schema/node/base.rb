module NxtSchema
  module Node
    class Base
      def initialize(node:, input: Undefined.new, parent:, context:, error_key:)
        @node = node
        @input = input
        @parent = parent
        @output = nil
        @error_key = error_key
        @context = context || parent&.context
        @coerced = false
        @coerced_nodes = parent&.coerced_nodes || []
        @is_root = parent.nil?
        @root = parent.nil? ? self : parent.root
        @errors = ErrorStore.new(self)
        @locale = node.options.fetch(:locale) { parent&.locale || 'en' }.to_s

        @index = error_key
        resolve_error_key(error_key)
      end

      attr_accessor :output, :node, :input
      attr_reader :parent, :context, :error_key, :coerced, :coerced_nodes, :root, :errors, :locale, :index

      def call
        raise NotImplementedError, 'Implement this in our sub class'
      end

      delegate :name, :options, to: :node

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

      def merge_errors(node)
        errors.merge_errors(node)
      end

      def run_validations
        return false unless coerced?

        node.validations.each do |validation|
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

      attr_writer :coerced, :root

      def coerce_input
        output = input.is_a?(Undefined) && node.omnipresent? ? input : node.type.call(input)
        self.output = output

      rescue Dry::Types::CoercionError, NxtSchema::Errors::CoercionError => error
        add_schema_error(error.message)
      end

      def apply_on_evaluators
        node.on_evaluators.each { |evaluator| evaluator.call(input, self, context) { |result| self.input = result } }
      end

      def maybe_evaluator_applies?
        @maybe_evaluator_applies ||= node.maybe_evaluators.inject(false) do |acc, evaluator|
          result = (acc || evaluator.call(input, self, context))

          if result
            self.output = input
            break true
          else
            false
          end
        end
      end

      def register_as_coerced_when_no_errors
        return unless valid?

        self.coerced = true
        coerced_nodes << self
      end

      def resolve_error_key(key)
        parts = [parent&.error_key].compact
        parts << (key.present? ? "#{node.name}[#{key}]" : node.name)
        @error_key = parts.join('.')
      end

      def coerced?(&block)
        block.call(self) if @coerced && block_given?
        @coerced
      end
    end
  end
end
