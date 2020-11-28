module NxtSchema
  module Node
    module Errors
      class ValidationError < ::String
        def initialize(application:, message:)
          super(message)
          @application = application
        end

        attr_reader :application
      end
    end
  end
end

