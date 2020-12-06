module NxtSchema
  module Node
    class Collection < Node::Base
      def call
        apply_on_evaluators
        child_nodes # build nodes here so we can access them even when invalid
        return self if maybe_evaluator_applies?

        coerce_input
        validate_filled
        return self unless valid?

        child_nodes.each_with_index do |item, index|
          child_node = item.call

          if !child_node.valid?
            merge_errors(child_node)
          else
            output[index] = child_node.output
          end
        end

        register_as_coerced_when_no_errors
        run_validations

        self
      end

      delegate :[], to: :child_nodes

      private

      def validate_filled
        add_schema_error('is not allowed to be empty') if input.blank? && !maybe_evaluator_applies?
      end

      def child_nodes
        @child_nodes ||= begin
          return [] unless input.respond_to?(:each_with_index)

          input.each_with_index.map do |item, index|
            build_child_node(item, index)
          end
        end

      end

      def build_child_node(item, error_key)
        sub_node.build_node(input: item, context: context, parent: self, error_key: error_key)
      end

      def sub_node
        @sub_node ||= node.sub_nodes.values.first
      end
    end
  end
end
