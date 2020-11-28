module NxtSchema
  module Node
    class ErrorStore < ::Hash
      def initialize(application)
        super()
        @application = application
      end

      attr_reader :application

      def add_schema_error(message:)
        add_error(
          application,
          NxtSchema::Node::Errors::SchemaError.new(
            application: application,
            message: message
          )
        )
      end

      def add_validation_error(message:)
        add_error(
          application,
          NxtSchema::Node::Errors::ValidationError.new(
            application: application,
            message: message
          )
        )
      end

      def merge_errors(application)
        merge!(application.errors)
      end

      def add_error(application, error)
        self[application.error_key] ||= []
        self[application.error_key] << error
      end

      # def schema_errors
      #   inject({}) do |acc, (k, v)|
      #     errors = v.select { |e| e.is_a?(NxtSchema::Node::Errors::SchemaError) }
      #     acc[k] = errors if errors.any?
      #     acc
      #   end
      # end
      #
      # def validation_errors
      #   inject({}) do |acc, (k, v)|
      #     errors = v.select { |e| e.is_a?(NxtSchema::Node::Errors::ValidationError) }
      #     acc[k] = errors if errors.any?
      #     acc
      #   end
      # end
    end
  end
end
