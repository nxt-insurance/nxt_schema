module NxtSchema
  module Node
    class DefaultValueEvaluator
      def initialize(node, evaluator_or_value)
        @node = node
        @evaluator_or_value = evaluator_or_value
      end

      attr_reader :node, :evaluator_or_value

      def call
        if evaluator_or_value.respond_to?(:call)
          Callable.new(evaluator_or_value).call(node)
        else
          evaluator_or_value
        end
      end
    end
  end
end
