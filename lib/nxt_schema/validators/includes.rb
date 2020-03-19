module NxtSchema
  module Validators
    class Includes < Validator
      def initialize(target)
        @target = target
      end

      register_as :includes
      attr_reader :target

      def build
        lambda do |node, value|
          if value.include?(target)
            true
          else
            message = translate_error(node.locale, value: value, target: target)
            node.add_error(message)
          end
        end
      end
    end
  end
end
