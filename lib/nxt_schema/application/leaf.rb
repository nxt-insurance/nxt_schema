module NxtSchema
  module Application
    class Leaf < Application::Base
      def call
        self.output = apply_type
        self
      end
    end
  end
end
