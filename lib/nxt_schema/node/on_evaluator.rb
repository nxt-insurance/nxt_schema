module NxtSchema
  module Node
    class OnEvaluator
      def initialize(condition:, value:)
        @condition = condition
        @value = value
      end

      def call(target = nil, *args)
        return unless Callable.new(condition, target, *args).call

        Callable.new(value, target, *args).call
      end

      private

      attr_reader :condition, :value
    end
  end
end
