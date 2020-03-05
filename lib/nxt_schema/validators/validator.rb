module NxtSchema
  module Validators
    class Validator
      def self.register_as(*keys)
        keys.each do |key|
          NxtSchema::Validators::Registry::VALIDATORS.register(key, self)
        end
      end
    end
  end
end
