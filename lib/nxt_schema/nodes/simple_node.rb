module NxtSchema
  module Nodes
    class SimpleNode < Node
      def validate(target)
        return self if target.is_a?(type)

        error_message = "Does not match type: #{type}"

        errors[target] = error_message
        add_flat_error(target, error_message)

        self
      end
    end
  end
end
