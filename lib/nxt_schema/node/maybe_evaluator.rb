module NxtSchema
  module Node
    class MaybeEvaluator
      def initialize(node, evaluator, value)
        @node = node
        @evaluator = evaluator
        @value = value
      end

      attr_reader :node, :evaluator, :value

      def call
        if evaluator.respond_to?(:call)
          Callable.new(evaluator).call(node, value)
        elsif value.is_a?(Symbol) && value.respond_to?(evaluator)
          Callable.new(evaluator).bind(value).call(node, value)
        else
          value == evaluator
        end
      end
    end
  end
end
