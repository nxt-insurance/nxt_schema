module NxtSchema
  module Node
    class Base
      def initialize(name:, value_type:, parent_node:, **options, &block)
        @name = name
        @parent_node = parent_node
        @options = options #TODO: Do we really need options?
        @value_type = value_type
        @level = parent_node ? parent_node.level + 1 : 0
        @is_root = parent_node.nil?
        @root = parent_node.nil? ? self : parent_node.root

        configure(&block) if block_given?
      end

      attr_accessor :name, :parent_node, :options, :value_type, :level, :root

      def apply(input, parent: nil)
        application_class.new(node: self, input: input, parent: parent).call
      end

      private

      def application_class
        @application_class ||= "NxtSchema::Application::#{self.class.name.demodulize}".constantize
      end

      def configure(&block)
        if block.arity == 1
          block.call(self)
        else
          instance_exec(&block)
        end
      end

      def root?
        @is_root
      end
    end
  end
end
