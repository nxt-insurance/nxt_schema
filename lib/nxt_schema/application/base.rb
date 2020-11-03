module NxtSchema
  module Application
    class Base
      def initialize(node:, input: MissingInput.new, parent:)
        @node = node
        @input = input
        @parent = parent
        @output = nil
        @errors = Errors.new(application: self, node: node)
      end

      attr_accessor :output, :node, :input
      attr_reader :parent, :errors

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
        self.output = type[input]
      rescue Dry::Types::ConstraintError, Dry::Types::CoercionError => error
        add_schema_error(error.message)
      end
    end
  end
end
