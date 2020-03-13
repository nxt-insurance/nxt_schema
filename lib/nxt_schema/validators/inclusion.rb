module NxtSchema
  module Validators
    class Inclusion < Validator
      def initialize(target, language:)
        @target = target
        @language = language
      end

      register_as :inclusion
      attr_reader :target, :language

      def build
        lambda do |node, value|
          if target.include?(value)
            true
          else
            node.add_error("#{value} not included in #{target}")
            false
          end
        end
      end
    end
  end
end
