module NxtSchema
  module Validations
    module Validators
      class Format < Validator
          def initialize(pattern)
          @pattern = pattern
        end

        register_as :format
        attr_reader :pattern

        def build
          lambda do |node, value|
            if value.match(pattern)
              true
            else
              node.add_error("#{value} does not match format #{pattern}")
              false
            end
          end
        end
      end
    end
  end
end