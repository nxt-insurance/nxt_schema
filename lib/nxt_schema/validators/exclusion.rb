module NxtSchema
  module Validators
      class Exclusion < Validator
        def initialize(target)
          @target = target
        end

        register_as :exclusion, :exclude
        attr_reader :target

        def build
          lambda do |node, value|
            if target.exclude?(value)
              true
            else
              node.add_error("#{target} should not contain #{value}")
              false
            end
          end
        end
      end
    end
end
