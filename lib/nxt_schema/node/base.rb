module NxtSchema
  module Node
    class Base
      def initialize(name:, type:, parent_node:, **options, &block)
        @name = name
        @parent_node = parent_node
        @options = options
        @level = parent_node ? parent_node.level + 1 : 0
        @is_root = parent_node.nil?
        @root = parent_node.nil? ? self : parent_node.root
        @optional = options.fetch(:optional, false)

        @type_system = resolve_type_system
        @type = resolve_type(type)

        @additional_keys_strategy = resolve_additional_keys_strategy
        application_class # memoize
        configure(&block) if block_given?
      end

      attr_accessor :name, :parent_node, :options, :type, :level, :root, :additional_keys_strategy
      attr_reader :type_system

      def apply(input, parent: nil)
        application_class.new(node: self, input: input, parent: parent).call
      end

      def root?
        @is_root
      end

      # def optional(&block)
      #   raise ArgumentError, 'A present node cannot be optional at the same time' if presence?
      #
      #   @optional = true
      #
      #   if block_given?
      #     configure(&block)
      #   else
      #     self
      #   end
      # end

      def optional?
        @optional
      end

      # def presence(&block)
      #   raise ArgumentError, 'A optional node cannot be present at the same time' if optional?
      #
      #   @presence = true
      #
      #   if block_given?
      #     configure(&block)
      #   else
      #     self
      #   end
      # end

      def presence?
        @presence
      end

      def any_of(&block)
        @all_of = false
        @any_of = true

        configure(&block)
      end

      def all_of(&block)
        @any_of = false
        @all_of = true

        configure(&block)
      end

      private

      attr_accessor :optional

      def resolve_type(name_or_type)
        root.send(:type_resolver).resolve(type_system, name_or_type)
      end

      def resolve_type_system
        TypeSystemResolver.new(node: self).call
      end

      def type_resolver
        @type_resolver ||= begin
          if root?
            TypeResolver.new
          else
            raise NoMethodError, 'type_resolver is only available on root node'
          end
        end
      end

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

      def resolve_additional_keys_strategy
        options.fetch(:additional_keys) { parent_node&.send(:additional_keys_strategy) || :allow }
      end
    end
  end
end
