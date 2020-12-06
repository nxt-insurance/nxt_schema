module NxtSchema
  module Node
    module Errors
      class ValidationError < ::String
        def initialize(node:, message:)
          super(message)
          @node = node
        end

        attr_reader :node
      end
    end
  end
end

