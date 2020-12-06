module NxtSchema
  module Validators
    class Excluded < Validator
      def initialize(target)
        @target = target
      end

      register_as :excluded_in
      attr_reader :target

      def build
        lambda do |node, value|
          if target.exclude?(value)
            true
          else
            message = translate_error(node.locale, target: target, value: value)
            node.add_error(message)
          end
        end
      end
    end
  end
end
