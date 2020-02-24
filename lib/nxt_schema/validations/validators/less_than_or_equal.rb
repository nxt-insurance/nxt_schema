module NxtSchema
  module Validations
    module Validators
      class LessThanOrEqual < Validator
        def initialize(threshold)
          @threshold = threshold
        end

        register_as :less_than_or_equal
        attr_reader :threshold

        def build
          lambda do |node, value|
            if value <= threshold
              true
            else
              node.add_error("#{value} should be less than or equal to #{threshold}")
              false
            end
          end
        end
      end
    end
  end
end