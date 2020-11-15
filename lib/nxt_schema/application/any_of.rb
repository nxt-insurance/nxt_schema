module NxtSchema
  module Application
    class AnyOf < Application::Base
      def valid?
        valid_application.present?
      end

      def call
        # TODO: We should check that this is not empty!

        if valid?
          self.output = valid_application.output
        else
          applications.each do |application|
            merge_errors(application)
          end
        end

        self
      end

      private

      def valid_application
        applications.find(&:valid?)
      end

      def applications
        @applications ||= nodes.map { |node| node.apply(input, context, self) }
      end

      def nodes
        @nodes ||= node.sub_nodes.values
      end
    end
  end
end
