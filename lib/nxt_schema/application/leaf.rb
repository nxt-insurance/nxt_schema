module NxtSchema
  module Application
    class Leaf < Application::Base
      def call
        coerce_input
        register_as_applied if valid?
        self
      end
    end
  end
end
