module NxtSchema
  module Application
    class Errors
      DEFAULT_ERROR_KEY = :itself

      def initialize(application:, node:)
        @application = application
        @node = node
        @schema_errors = {}
        @validation_errors = {}
      end

      attr_reader :application, :node, :schema_errors, :validation_errors

      def all
        {
          schema_errors: schema_errors,
          validation_errors: validation_errors
        }
      end

      alias to_h all

      def add_schema_error(error, index: DEFAULT_ERROR_KEY)
        schema_errors_store(index) << error
      end

      def add_validation_error(error, index: DEFAULT_ERROR_KEY)
        validation_errors_store(index) << error
      end

      def merge_schema_errors(child_application)
        errors = child_application.schema_errors
        child_error_key = child_application.error_key

        if errors.is_a?(::Hash)
          if errors.keys == [DEFAULT_ERROR_KEY]
            schema_errors[child_error_key] = errors.fetch(DEFAULT_ERROR_KEY) + schema_errors.fetch(child_error_key, [])
          else
            schema_errors[child_error_key] ||= {}
            schema_errors[child_error_key].merge!(errors)
          end
        else
          schema_errors[child_error_key] ||= []
          schema_errors[child_error_key] << errors
        end
      end

      def any?
        schema_errors.any? || validation_errors.any?
      end

      def schema_errors_store(error_key)
        schema_errors[error_key] ||= []
      end

      def validation_errors_store(error_key)
        validation_errors[error_key] ||= []
      end
    end
  end
end
