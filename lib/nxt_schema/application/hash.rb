module NxtSchema
  module Application
    class Hash < Application::Base
      def call
        coerce_input
        return self unless valid?

        apply_additional_keys_strategy

        keys.each do |key|
          sub_node = sub_nodes[key]
          value = input[key]
          current_application = sub_node.apply(value, parent: self)

          if current_application.errors.any?
            merge_schema_errors(current_application.schema_errors, index: key)
          else
            output[key] = current_application.output
          end
        end

        self
      end

      def keys
        sub_nodes.keys
      end

      def additional_keys
        @additional_keys ||= input.keys - keys
      end

      def additional_keys?
        additional_keys.any?
      end

      def apply_additional_keys_strategy
        return if allow_additional_keys?
        return unless additional_keys?

        if restrict_addition_keys?
          add_schema_error("Additional keys are not allowed: #{additional_keys}")
        elsif reject_additional_keys?
          output.except!(*additional_keys)
        end
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
    end
  end
end
