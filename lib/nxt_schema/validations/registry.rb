module NxtSchema
  module Validations
    class Registry
      extend NxtRegistry

      VALIDATORS = registry :validators, call: false do

      end
    end
  end
end