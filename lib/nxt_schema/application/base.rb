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
      end

      attr_accessor :output, :node, :input
      attr_reader :parent, :errors, :context, :error_key

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
    end
  end
end
