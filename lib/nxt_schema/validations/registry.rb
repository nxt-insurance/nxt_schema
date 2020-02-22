module NxtSchema
  module Validations
    class Registry
      extend NxtRegistry

      VALIDATORS = registry :validators do
        register(:greater_than, lambda do |threshold|
          lambda do |node, value|
            if value > threshold
              true
            else
              node.add_error("#{node.name}: #{value} must be greater #{threshold}")
              false
            end
          end
        end)
      end
    end
  end
end