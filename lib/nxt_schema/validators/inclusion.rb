module NxtSchema
  module Validators
    class Inclusion < Validator
      def initialize(target)
        @target = target
      end

      register_as :inclusion
      attr_reader :target

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
