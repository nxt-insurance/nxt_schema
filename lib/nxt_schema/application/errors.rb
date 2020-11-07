module NxtSchema
  module Application
    class Errors
      DEFAULT_ERROR_KEY = :itself

      def initialize(application:, node:)
        @application = application
        @node = node
        @schema_errors = {}
        @validation_errors = {}
        @flat_schema_errors = {}
      end

      attr_reader :application, :node, :schema_errors, :validation_errors, :flat_schema_errors

      def all
        {
          schema_errors: schema_errors,
          validation_errors: validation_errors
        }
      end

      alias to_h all

      def add_schema_error(error)
        schema_errors[DEFAULT_ERROR_KEY] ||= []
        schema_errors[DEFAULT_ERROR_KEY] << error
      end

      def merge_schema_errors(child_application)
        child_errors = child_application.schema_errors
        child_error_key = child_application.error_key

        if nested_errors?(child_errors)
          schema_errors[child_error_key] ||= {}
          schema_errors[child_error_key].merge!(child_errors)
        else
          schema_errors[child_error_key] = child_errors.fetch(DEFAULT_ERROR_KEY) # + schema_errors.fetch(child_error_key, [])
        end

        flat_schema_errors.merge!(child_application.flat_schema_errors)
      end

      def any?
        schema_errors.any? || validation_errors.any?
      end

      def nested_errors?(errors)
        errors.keys != [DEFAULT_ERROR_KEY]
      end

      def add_flat_schema_error(error)
        flat_schema_errors[application.nested_error_key] ||= []
        flat_schema_errors[application.nested_error_key] << error
      end
    end
  end
end
