module NxtSchema
  module Application
    class Leaf < Application::Base
      def call
        coerce_input
        register_as_applied
        self
      end
    end
  end
end
