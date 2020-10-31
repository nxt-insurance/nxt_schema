module NxtSchema
  module Application
    class Leaf < Application::Base
      def call
        coerce_input
        self
      end
    end
  end
end
