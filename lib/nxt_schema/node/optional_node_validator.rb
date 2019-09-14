module NxtSchema
  module Node
    class OptionalNodeValidator
      def initialize(validator)
        @validator = validator
      end

      def call(node, value)
        evaluator_args = [node, value]
        unless validator.call(*evaluator_args.take(validator.arity))
          node.add_error("Required key missing!")
        end
      end

      private

      attr_reader :validator
    end
  end
end
