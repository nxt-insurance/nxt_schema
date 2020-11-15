module NxtSchema
  module Application
    class AnyOf < Application::Base
      def valid?
        valid_application.present?
      end

      def call
        # TODO: We should check that this is not empty!
        child_applications.map(&:call)

        if valid?
          self.output = valid_application.output
        else
          child_applications.each do |application|
            merge_errors(application)
          end
        end

        self
      end

      private

      delegate :[], to: :child_applications

      def valid_application
        child_applications.find(&:valid?)
      end

      def child_applications
        @child_applications ||= nodes.map { |node| node.build_application(input, context, self) }
      end

      def nodes
        @nodes ||= node.sub_nodes.values
      end
    end
  end
end
