module NxtSchema
  module Validators
      class LessThan < Validator
        def initialize(threshold)
          @threshold = threshold
        end

        register_as :less_than
        attr_reader :threshold

        def build
          lambda do |node, value|
            if value < threshold
              true
            else
              node.add_error("#{value} should be less than #{threshold}")
              false
            end
          end
        end
      end
    end
end
