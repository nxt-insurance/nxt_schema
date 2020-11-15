module NxtSchema
  module Application
    class GlobalErrorStore < ::Hash
      def add_schema_error(application, error)
        self[application.error_key] ||= []
        self[application.error_key] << NxtSchema::Application::Errors::SchemaError.new(
          application: application,
          message: error
        )
      end

      def add_validation_error(application, error)
        self[application.error_key] ||= []
        self[application.error_key] << NxtSchema::Application::Errors::ValidationError.new(
          application: application,
          message: error
        )
      end

      # def schema_errors
      #   inject({}) do |acc, (k, v)|
      #     errors = v.select { |e| e.is_a?(NxtSchema::Application::Errors::SchemaError) }
      #     acc[k] = errors if errors.any?
      #     acc
      #   end
      # end
      #
      # def validation_errors
      #   inject({}) do |acc, (k, v)|
      #     errors = v.select { |e| e.is_a?(NxtSchema::Application::Errors::ValidationError) }
      #     acc[k] = errors if errors.any?
      #     acc
      #   end
      # end
    end
  end
end