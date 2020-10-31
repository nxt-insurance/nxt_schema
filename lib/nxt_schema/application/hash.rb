module NxtSchema
  module Application
    class Hash < Application::Base
      def call
        coerce_input

        input.each do |key, value|
          sub_node = sub_nodes[key]
          output[key] = sub_node.apply(value, parent: self).output
        end

        self
      end
    end
  end
end
