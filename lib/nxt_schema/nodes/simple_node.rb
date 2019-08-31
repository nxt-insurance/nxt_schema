module NxtSchema
  module Nodes
    class SimpleNode < Node
      def validate(target)
        return self if target.is_a?(type)

        add_error(target, "Does not match type: #{type}")

        self
      end
    end
  end
end
