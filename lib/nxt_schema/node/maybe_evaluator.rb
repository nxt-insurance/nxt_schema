module NxtSchema
  module Node
    class MaybeEvaluator
      def initialize(value:)
        @value = value
      end

      def call(target = nil, *args)
        Callable.new(value, target, *args).call
      end

      private

      attr_reader :value
    end
  end
end
