module NxtSchema
  module Application
    class Collection < Application::Base
      def call
        apply_on_evaluators
        return self if maybe_evaluator_applies?

        coerce_input
        validate_filled
        return self unless valid?

        build_child_applications(input).each_with_index do |item, index|
          current_application = item.call

          if !current_application.valid?
            merge_errors(current_application)
          else
            output[index] = current_application.output
          end
        end

        register_as_applied_when_valid
        run_validations

        self
      end

      delegate :[], to: :child_applications

      private

      def validate_filled
        add_schema_error('is not allowed to be empty') if input.blank? && !maybe_evaluator_applies?
      end

      def build_child_applications(input)
        input.each_with_index do |item, index|
          build_child_application(item, index)
        end

        child_applications
      end

      def build_child_application(item, error_key)
        child = sub_node.build_application(item, nil, self, error_key)
        child_applications << child
      end

      def sub_node
        @sub_node ||= sub_nodes.values.first
      end

      def child_applications
        @child_applications ||= []
      end
    end
  end
end
