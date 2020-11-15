module NxtSchema
  module Application
    class Leaf < Application::Base
      def call
        apply_on_evaluators
        return self if maybe_evaluator_applies?

        coerce_input
        register_as_applied_when_valid
        run_validations
        self
      end
    end
  end
end
