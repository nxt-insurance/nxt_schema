module NxtSchema
  module Application
    class Errors
      DEFAULT_ERROR_INDEX = :itself

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

      def add_schema_error(error, index: DEFAULT_ERROR_INDEX)
        schema_errors_store(index) << error
      end

      def add_validation_error(error, index: DEFAULT_ERROR_INDEX)
        validation_errors_store(index) << error
      end

      def merge_schema_errors(child_application)
        errors = child_application.schema_errors
        index = child_application.error_key

        if errors.is_a?(::Hash)
          if errors.keys == [DEFAULT_ERROR_INDEX]
            schema_errors[index] = errors.fetch(DEFAULT_ERROR_INDEX) + schema_errors.fetch(index, [])
          else
            schema_errors[index] ||= {}
            schema_errors[index].merge!(errors)
          end
        else
          schema_errors[index] ||= []
          schema_errors[index] << errors
        end
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
