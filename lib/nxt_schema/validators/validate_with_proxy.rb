module NxtSchema
  module Validator
    class ValidateWithProxy
      def initialize(node)
        @node = node
        @aggregated_errors = []
      end

      attr_reader :node

      delegate_missing_to :node

      def validate(&block)
        result = instance_exec(&block)
        return if result

        copy_aggregated_errors_to_node
      end

      def add_error(error)
        aggregated_errors << error
        false
      end

      def copy_aggregated_errors_to_node
        aggregated_errors.each do |error|
          node.add_error(error)
        end
      end

      private

      attr_reader :aggregated_errors

      def validator(key, *args)
        validator = node.node.send(:validator, key, *args)
        validator.call(self, node.input)
      end
    end
  end
end
