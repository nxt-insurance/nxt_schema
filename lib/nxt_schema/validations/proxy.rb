module NxtSchema
  module Validations
    class Proxy
      def initialize(node)
        @node = node
        @aggregated_errors = []
      end

      attr_reader :node

      delegate_missing_to :node

      def validate(&block)
        result = instance_exec(&block)
        return if result

        copy_errors_to_node
      end

      def add_error(error)
        aggregated_errors << error
      end

      def copy_errors_to_node
        aggregated_errors.each do |error|
          node.add_error(error)
        end
      end

      private

      attr_reader :aggregated_errors

      def validator(key, *args)
        validator = node.validator(key, *args)
        validator.call(self, node.value)
      end
    end
  end
end