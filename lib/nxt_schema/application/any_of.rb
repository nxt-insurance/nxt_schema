module NxtSchema
  module Application
    class AnyOf < Application::Base
      def valid?
        valid_application.present?
      end

      def call
        # TODO: We should check that this is not empty!
        self.output = valid_application.output if no_local_errors?
        self
      end

      private

      def valid_application
        applications.find(&:no_local_errors?)
      end

      def applications
        @applications ||= nodes.map { |node| node.apply(input, context, self, node.name) }
      end

      def nodes
        @nodes ||= node.sub_nodes.values
      end
    end
  end
end
