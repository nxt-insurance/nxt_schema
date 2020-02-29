module NxtSchema
  module Validations
    module Validators
      class Pattern < Validator
          def initialize(pattern)
          @pattern = pattern
        end

        register_as :format, :pattern
        attr_reader :pattern

        def build
          lambda do |node, value|
            if value.match(pattern)
              true
            else
              node.add_error("#{value} does not match #{pattern}")
              false
            end
          end
        end
      end
    end
  end
end