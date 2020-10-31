module NxtSchema
  module Application
    class Array < Application::Base
      def call
        self.output = apply_type
        # TODO: For now get the first node spec of the array
        sub_node = node.send(:sub_nodes).values.first
        # TODO: Ask node for sub_node_evaluation

        input.each_with_index do |item, index|
          output[index] = sub_node.apply(item, parent: self).output
        end

        self
      end
    end
  end
end
