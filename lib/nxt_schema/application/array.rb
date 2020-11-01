module NxtSchema
  module Application
    class Array < Application::Base
      def call
        coerce_input
        add_schema_error('is not allowed to be empty') if input.empty?
        return self unless valid?

        input.each_with_index do |item, index|
          current_application = apply_item(item)

          if current_application.errors.any?
            merge_schema_errors(current_application.schema_errors, index: index)
          else
            output[index] = current_application.output
          end
        end

        self
      end

      private

      def apply_item(item)
        sub_node.apply(item, parent: self)
      end

      # TODO: Respect sub_node_evaluation
      def sub_node
        @sub_node ||= sub_nodes.values.first
      end
    end
  end
end
