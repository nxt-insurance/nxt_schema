module NxtSchema
  module Validations
    module Validators
      class GreaterThan < Validator
        def initialize(threshold)
          @threshold = threshold
        end

        register_as :greater_than
        attr_reader :threshold

        def build
          lambda do |node, value|
            if value > threshold
              true
            else
              node.add_error("#{value} should be greater #{threshold}")
              false
            end
          end
        end
      end
    end
  end
end