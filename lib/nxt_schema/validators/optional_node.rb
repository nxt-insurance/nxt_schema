module NxtSchema
  module Validators
    class OptionalNode < Validator
      def initialize(conditional, missing_key)
        @conditional = conditional
        @missing_key = missing_key
      end

      register_as :optional_node
      attr_reader :conditional, :missing_key

      def build
        lambda do |node, value|
          args = [node, value]

          if conditional.call(*args.take(conditional.arity))
            true
          else
            message = ErrorMessages.resolve(node.locale, :required_key_missing, key: missing_key, target: node.value)
            node.add_error(message)
          end
        end
      end
    end
  end
end
