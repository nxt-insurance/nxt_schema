module NxtSchema
  module Validations
    class Registry
      extend NxtRegistry

      VALIDATORS = registry :validators, call: false, memoize: false do
        register(:greater_than, lambda do |threshold|
          lambda do |node, value|
            if value > threshold
              true
            else
              node.add_error("#{value} should be greater #{threshold}")
              false
            end
          end
        end)

        register(:format, lambda do |pattern|
          lambda do |node, value|
            if value.match(pattern)
              true
            else
              node.add_error("#{value} does not match format #{pattern}")
              false
            end
          end
        end)
      end
    end
  end
end