module NxtSchema
  module Node
    class Leaf < Node::Base
      def call
        apply_on_evaluators
        return self if maybe_evaluator_applies?

        coerce_input
        register_as_coerced_when_no_errors
        run_validations
        self
      end
    end
  end
end
