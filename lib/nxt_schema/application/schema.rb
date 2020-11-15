module NxtSchema
  module Application
    class Schema < Application::Base
      def call
        coerce_input
        return self unless valid?
        return self if maybe_evaluator_applies?

        flag_missing_keys
        apply_additional_keys_strategy

        keys.each do |key|
          build_child_application(key)
        end

        child_applications.each do |key, child|
          current_application = child.call

          if !current_application.valid?
            merge_errors(current_application)
          else
            output[key] = current_application.output
          end
        end

        register_as_applied if valid?
        run_validations
        self
      end

      # TODO: Make private what should be private

      def keys
        sub_nodes.reject { |key, _| optional_and_not_given_key?(key) }.keys
      end

      def additional_keys
        @additional_keys ||= input.keys - keys
      end

      def optional_and_not_given_key?(key)
        sub_nodes[key].optional? && !input.key?(key)
      end

      def additional_keys?
        additional_keys.any?
      end

      # TODO: Should we raise directly when keys are missing?
      def missing_keys
        @missing_keys ||= sub_nodes.reject { |_, node| node.omnipresent? || node.optional? }.keys - input.keys
      end

      def apply_additional_keys_strategy
        return if allow_additional_keys?
        return unless additional_keys?

        if restrict_addition_keys?
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
        additional_keys_strategy == :allow
      end

      def reject_additional_keys?
        additional_keys_strategy == :reject
      end

      def restrict_addition_keys?
        additional_keys_strategy == :restrict
      end

      def child_applications
        @child_applications ||= {}
      end

      delegate :[], to: :child_applications

      private

      def build_child_application(key)
        sub_node = sub_nodes[key]
        value = input.key?(key) ? input[key] : MissingInput.new
        child = sub_node.build_application(value, nil, self)
        child_applications[key] = child
      end
    end
  end
end
