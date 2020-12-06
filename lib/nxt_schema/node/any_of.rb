module NxtSchema
  module Node
    class AnyOf < Node::Base
      def valid?
        valid_node.present?
      end

      def call
        child_nodes.map(&:call)

        if valid?
          self.output = valid_node.output
        else
          child_nodes.each do |node|
            merge_errors(node)
          end
        end

        self
      end

      private

      delegate :[], to: :child_nodes

      def valid_node
        child_nodes.find(&:valid?)
      end

      def child_nodes
        @child_nodes ||= nodes.map { |node| node.build_node(input: input, context: context, parent: self) }
      end

      def nodes
        @nodes ||= node.sub_nodes.values
      end
    end
  end
end
