module NxtSchema
  module Validators
    class Exclusion < Validator
      def initialize(target, language:)
        @target = target
        @language = language
      end

      register_as :exclusion, :exclude
      attr_reader :target, :language

      def build
        lambda do |node, value|
          if target.exclude?(value)
            true
          else
            node.add_error("#{target} should not contain #{value}")
            false
          end
        end
      end
    end
  end
end
