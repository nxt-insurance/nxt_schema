module NxtSchema
  module Application
    class LocalErrors < ::Array
      def initialize(application)
        super()
        @application = application
      end

      attr_reader :application

      def add_schema_error(error)
        self << NxtSchema::Application::Errors::SchemaError.new(application: application, message: error)
      end

      def add_validation_error(error)
        self << NxtSchema::Application::Errors::ValidationError.new(application: application, message: error)
      end

      def schema_errors
        select { |error| error.is_a?(NxtSchema::Application::Errors::SchemaError) }
      end

      def validation_errors
        select { |error| error.is_a?(NxtSchema::Application::Errors::ValidationError) }
      end
    end
  end
end
