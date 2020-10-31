module NxtSchema
  module Application
    class Errors
      DEFAULT_ERROR_INDEX = :itself

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

      def add_schema_error(error, index: DEFAULT_ERROR_INDEX)
        schema_errors_store(index) << error
      end

      def add_validation_error(error, index: DEFAULT_ERROR_INDEX)
        validation_errors_store(index) << error
      end

      def any?
        schema_errors.any? || validation_errors.any?
      end

      def schema_errors_store(index)
        schema_errors[index] ||= []
      end

      def validation_errors_store(index)
        validation_errors[index] ||= []
      end
    end
  end
end
