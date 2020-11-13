module NxtSchema
  module Application
    module Errors
      class SchemaError < ::String
        def initialize(application:, message:)
          super(message)
          @application = application
        end

        attr_reader :application

        def kind
          self.class.name
        end
      end
    end
  end
end
