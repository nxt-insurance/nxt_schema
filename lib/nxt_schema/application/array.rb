module NxtSchema
  module Application
    class Array < Application::Base
      def call
        coerce_input
        return self unless valid?

        # TODO: How can we validate input is not empty?

        input.each_with_index do |item, index|
          current_application = apply_item(item)

          if current_application.errors.any?
            add_schema_error(current_application.schema_errors, index: index)
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
