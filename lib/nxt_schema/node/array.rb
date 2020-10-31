module NxtSchema
  module Node
    class Array < Node::Base
      include HasSubNodes

      DEFAULT_TYPE = NxtSchema::Types::Strict::Array

      def initialize(name:, value_type: DEFAULT_TYPE, parent_node:, **options, &block)
        super
      end

      def any_of(&block)
        @all_of = false
        @any_of = true

        configure(&block)
        self
      end

      def all_of(&block)
        @any_of = false
        @all_of = true

        configure(&block)
        self
      end

      def sub_nodes_evaluation?(value)
        value == (@all_of ? :all : :any)
      end
    end
  end
end
