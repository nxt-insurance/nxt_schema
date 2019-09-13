module NxtSchema
  module Node
    class OptionalNodeValidator
      def initialize(validator)
        @validator = validator
      end

      def call(node, value)
        evaluator_args = [node, value]
        validator.call(*evaluator_args.take(validator.arity))
      end

      private

      attr_reader :validator
    end
  end
end
