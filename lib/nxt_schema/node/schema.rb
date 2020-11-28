module NxtSchema
  module Node
    class Schema < Node::Base
      def call
        apply_on_evaluators
        child_applications # build applications here so we can access them even when invalid
        return self if maybe_evaluator_applies?

        coerce_input
        return self unless valid?

        flag_missing_keys
        apply_additional_keys_strategy

        child_applications.each do |key, child|
          current_application = child.call

          if !current_application.valid?
            merge_errors(current_application)
          else
            output[key] = current_application.output
          end
        end

        transform_keys
        register_as_applied_when_valid
        run_validations
        self
      end

      delegate :[], to: :child_applications

      private

      def transform_keys
        transformer = node.key_transformer
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

      def child_applications
        @child_applications ||= begin
          keys.inject({}) do |acc, key|
            child_application = build_child_application(key)
            acc[key] = child_application if child_application.present?
            acc
          end
        end
      end

      def build_child_application(key)
        sub_node = node.sub_nodes[key]
        return unless sub_node.present?

        value = input_has_key?(input, key) ? input[key] : MissingInput.new
        sub_node.build_application(input: value, context: context, parent: self)
      end

      def input_has_key?(input, key)
        input.respond_to?(:key?) && input.key?(key)
      end
    end
  end
end
