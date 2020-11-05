module NxtSchema
  module Application
    class AnyOf < Application::Base
      def valid?
        valid_result.present?
      end

      def call
        # TODO: We should check that this is not empty!

        if valid?
          self.output = valid_result.output
        else
          collect_schema_errors.each do |index, error|
            merge_schema_errors(error, index: index)
          end
        end

        self
      end

      private

      def collect_schema_errors
        @collect_schema_errors ||= results.inject({}) do |acc, result|
          acc[result.name] = result.schema_errors
          acc
        end
      end

      def valid_result
        results.find(&:valid?)
      end

      def results
        @results ||= nodes.map { |node| node.apply(input, context, self) }
      end

      def nodes
        @nodes ||= node.sub_nodes.values
      end
    end
  end
end
