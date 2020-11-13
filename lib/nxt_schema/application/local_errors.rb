module NxtSchema
  module Application
    class LocalErrors
      def initialize(application)
        @application = application
        @schema_errors = []
        @validation_errors = []
      end

      attr_reader :application, :schema_errors, :validation_errors

      def all
        {
          schema_errors: schema_errors,
          validation_errors: validation_errors
        }
      end

      alias to_h all

      def add_schema_error(error)
        schema_errors << error
      end

      def add_validation_error(error)
        validation_errors << error
      end

      def any?
        schema_errors.any? || validation_errors.any?
      end
    end
  end
end
