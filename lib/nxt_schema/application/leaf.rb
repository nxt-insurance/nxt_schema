module NxtSchema
  module Application
    class Leaf < Application::Base
      def call
        coerce_input
        register_if_applied
        self
      end
    end
  end
end
