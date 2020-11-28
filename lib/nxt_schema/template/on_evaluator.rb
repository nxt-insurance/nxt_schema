module NxtSchema
  module Template
    class OnEvaluator
      def initialize(condition:, value:)
        @condition = condition
        @value = value
      end

      def call(target = nil, *args, &block)
        return unless condition_applies?(target, *args)

        result = Callable.new(value, target, *args).call
        block.yield(result)
      end

      private

      def condition_applies?(target, *args)
        Callable.new(condition, target, *args).call
      end

      attr_reader :condition, :value
    end
  end
end
