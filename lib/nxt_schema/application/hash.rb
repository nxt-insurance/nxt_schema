module NxtSchema
  module Application
    class Hash < Application::Base
      def call
        coerce_input

        keys.each do |key|
          sub_node = sub_nodes[key]
          value = input[key]
          current_application = sub_node.apply(value, parent: self)

          if current_application.errors.any?
            add_schema_error(current_application.schema_errors, index: key)
          else
            output[key] = current_application.output
          end
        end

        self
      end

      def keys
        # TODO: Depending on key strategy use keys from input union or those from schema
        sub_nodes.keys
      end
    end
  end
end
