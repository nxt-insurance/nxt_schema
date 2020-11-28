module NxtSchema
  module Template
    class MaybeEvaluator
      def initialize(value:)
        @value = value
      end

      def call(target = nil, *args)
        evaluator = evaluator(target, *args)

        if evaluator.value?
          # When a value was given we check if this equals to the input
          evaluator.call == target
        else
          evaluator.call
        end
      end

      private

      def evaluator(target, *args)
        Callable.new(value, target, *args)
      end

      attr_reader :value
    end
  end
end
