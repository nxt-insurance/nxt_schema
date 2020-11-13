module NxtSchema
  module Application
    class ApplicationErrors < ::Hash
      def initialize
        super
        self[:schema_errors] = {}
        self[:validation_errors] = {}
      end

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

      def schema_errors
        self[:schema_errors]
      end

      def validation_errors
        self[:validation_errors]
      end
    end
  end
end
