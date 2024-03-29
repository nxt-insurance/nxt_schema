module NxtSchema
  module Node
    class Schema < Node::Base
      def call
        apply_on_evaluators
        child_nodes # build nodes here so we can access them even when invalid
        return self if maybe_evaluator_applies?

        coerce_input
        return self unless valid?

        flag_missing_keys
        apply_additional_keys_strategy

        child_nodes.each do |key, child|
          current_node = child.call

          if !current_node.valid?
            merge_errors(current_node)
          else
            output[key] = current_node.output
          end
        end

        transform_output_keys
        register_as_coerced_when_no_errors
        run_validations
        self
      end

      delegate :[], to: :child_nodes

      private

      def transform_output_keys
        transformer = node.output_keys_transformer
        return unless transformer && output.respond_to?(:transform_keys!)

        output.transform_keys!(&transformer)
      end

      def keys
        @keys ||= node.sub_nodes.reject { |key, _| optional_and_not_given_key?(key) }.keys
      end

      def additional_keys
        @additional_keys ||= input.keys - keys
      end

      def optional_and_not_given_key?(key)
        node.sub_nodes[key].optional? && !input.key?(key)
      end

      def additional_keys?
        additional_keys.any?
      end

      def missing_keys
        @missing_keys ||= node.sub_nodes.reject { |_, node| node.omnipresent? || node.optional? }.keys - input.keys
      end

      def apply_additional_keys_strategy
        return if allow_additional_keys?
        return unless additional_keys?

        if restrict_additional_keys?
          add_schema_error("Additional keys are not allowed: #{additional_keys}")
        elsif reject_additional_keys?
          self.output = output.except(*additional_keys)
        end
      end

      def flag_missing_keys
        return if missing_keys.empty?

        add_schema_error("The following keys are missing: #{missing_keys}")
      end

      def allow_additional_keys?
        node.additional_keys_strategy == :allow
      end

      def reject_additional_keys?
        node.additional_keys_strategy == :reject
      end

      def restrict_additional_keys?
        node.additional_keys_strategy == :restrict
      end

      def child_nodes
        @child_nodes ||= begin
          keys.inject({}) do |acc, key|
            child_node = build_child_node(key)
            acc[key] = child_node if child_node.present?
            acc
          end
        end
      end

      def build_child_node(key)
        sub_node = node.sub_nodes[key]
        return unless sub_node.present?

        value = input_has_key?(input, key) ? input[key] : Undefined.new
        sub_node.build_node(input: value, context: context, parent: self)
      end

      def input_has_key?(input, key)
        input.respond_to?(:key?) && input.key?(key)
      end
    end
  end
end
