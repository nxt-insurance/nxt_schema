module NxtSchema
  module Validations
    module Validators
      GreaterThanOrEqual = lambda do |threshold|
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