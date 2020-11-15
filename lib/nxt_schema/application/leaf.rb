module NxtSchema
  module Application
    class Leaf < Application::Base
      def call
        coerce_input
        register_as_applied if local_errors.empty?
        self
      end
    end
  end
end
