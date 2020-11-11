module NxtSchema
  module Application
    class Collection < Application::Base
      def call
        coerce_input
        validate_filled
        return self unless valid?
        return self if maybe_evaluator_applies?

        input.each_with_index do |item, index|
          current_application = apply_item(item, index)

          if current_application.errors.any?
            merge_schema_errors(current_application)
          else
            output[index] = current_application.output
          end
        end

        register_as_applied
        self
      end

      private

      def validate_filled
        add_schema_error('is not allowed to be empty') if input.empty? && !maybe_evaluator_applies?
      end

      def apply_item(item, error_key)
        sub_node.apply(item, nil, self, error_key)
      end

      def sub_node
        @sub_node ||= sub_nodes.values.first
      end
    end
  end
end
