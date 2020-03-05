module NxtSchema
  module Validators
    class Registry
      extend NxtRegistry

      VALIDATORS = registry :validators, call: false do

      end
    end
  end
end
