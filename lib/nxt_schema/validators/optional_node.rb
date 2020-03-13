module NxtSchema
  module Validators
    class OptionalNode < Validator
      def initialize(conditional, missing_key, language:)
        @conditional = conditional
        @missing_key = missing_key
        @language = language
      end

      register_as :optional_node
      attr_reader :conditional, :missing_key, :language

      def build
        lambda do |node, value|
          args = [node, value]

          if conditional.call(*args.take(conditional.arity))
            true
          else
            node.add_error("Required key :#{missing_key} is missing in #{node.value}")
            false
          end
        end
      end
    end
  end
end
