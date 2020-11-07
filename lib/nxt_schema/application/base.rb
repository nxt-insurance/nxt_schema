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

        resolve_nested_error_key
      end

      attr_accessor :output, :node, :input
      attr_reader :parent, :errors, :context, :error_key, :nested_error_key

      def call
        raise NotImplementedError, 'Implement this in our sub class'
      end

      delegate :schema_errors,
        :validation_errors,
        :add_schema_error,
        :add_validation_error,
        :merge_schema_errors,
        to: :errors

      delegate_missing_to :node

      def valid?
        !errors.any?
      end

      private

      def coerce_input
        output = input.is_a?(MissingInput) && node.omnipresent? ? input : type[input]
        self.output = output
      rescue Dry::Types::ConstraintError, Dry::Types::CoercionError => error
        add_schema_error(error.message)
      end

      def resolve_nested_error_key
        parts = []

        if parent
          parts << parent.nested_error_key
        else
          parts << name
        end

        parts << node.name if error_key.is_a?(Integer)
        parts << error_key
        parts.compact!
        parts.reject! { |part| part == Application::Errors::DEFAULT_ERROR_KEY }
        @nested_error_key = parts.join('.')
      end
    end
  end
end
