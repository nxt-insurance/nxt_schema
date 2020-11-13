module NxtSchema
  module Application
    class ApplicationErrors
      def initialize
        @schema_errors = {}
        @validation_errors = {}
      end

      attr_reader :schema_errors, :validation_errors

      def all
        {
          schema_errors: schema_errors,
          validation_errors: validation_errors
        }
      end

      alias to_h all

      def any?
        schema_errors.any? || validation_errors.any?
      end

      def add_schema_error(application, error)
        schema_errors[application.error_key] ||= []
        schema_errors[application.error_key] << error
      end

      def add_validation_error(application, error)
        validation_errors[application.error_key] ||= []
        validation_errors[application.error_key] << error
      end
    end
  end
end
