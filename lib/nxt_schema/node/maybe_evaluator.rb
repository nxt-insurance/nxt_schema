module NxtSchema
  module Node
    class MaybeEvaluator
      def initialize(evaluator, value)
        @evaluator = evaluator
        @value = value
      end

      attr_reader :evaluator, :value

      def call
        if evaluator.respond_to?(:call)
          evaluator.call(value)
        elsif value.is_a?(Symbol) && value.respond_to?(evaluator)
          value.send(evaluator)
        else
          value == evaluator
        end
      end
    end
  end
end
