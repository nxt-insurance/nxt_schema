module NxtSchema
  module Validator
    class ValidateWithProxy
      def initialize(application)
        @application = application
        @aggregated_errors = []
      end

      attr_reader :application

      delegate_missing_to :application

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
          application.add_error(error)
        end
      end

      private

      attr_reader :aggregated_errors

      def validator(key, *args)
        validator = application.node.send(:validator, key, *args)
        validator.call(self, application.input)
      end
    end
  end
end
