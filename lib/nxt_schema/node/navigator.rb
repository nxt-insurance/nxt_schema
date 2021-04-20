module NxtSchema
  module Node
    class Navigator
      def initialize(path, node)
        @path = path
        @node = node
      end

      def call
        return reference_node unless parts.any?
        parts.inject(reference_node) { |acc, operation| operation == '..' ? acc.parent : acc[operation.to_sym] }
      end

      private

      attr_reader :path, :node

      # /level_1/
      # / => root
      # ../
      # ./ => itself

      def parts
        @parts ||= path.split('/').reject { |part| part.blank? || part == '.' }
      end

      def reference_node
        @reference_node ||= path.starts_with?('/') ? node.root : node
      end
    end
  end
end
