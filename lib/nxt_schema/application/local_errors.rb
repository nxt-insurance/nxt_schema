module NxtSchema
  module Application
    class LocalErrors < ::Hash
      def initialize(application)
        super()
        @application = application
        self[:schema_errors] = []
        self[:validation_errors] = []
      end

      attr_reader :application

      def any?
        schema_errors.any? || validation_errors.any?
      end

      def add_schema_error(error)
        schema_errors << error
      end

      def add_validation_error(error)
        validation_errors << error
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
