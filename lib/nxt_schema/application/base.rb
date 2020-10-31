module NxtSchema
  module Application
    class Base
      def initialize(node:, input:, parent:)
        @node = node
        @input = input
        @parent = parent
        @output = nil
        @errors = Errors.new
      end

      attr_accessor :output, :node, :input
      attr_reader :parent, :errors

      def call
        raise NotImplementedError, 'Implement this in our sub class'
      end

      delegate :add_schema_error, :add_validation_error, to: :errors
      delegate_missing_to :node

      private

      def coerce_input
        self.output = value_type[input]
      rescue Dry::Types::ConstraintError, Dry::Types::CoercionError => error
        add_schema_error(error.message)
      end
    end
  end
end
