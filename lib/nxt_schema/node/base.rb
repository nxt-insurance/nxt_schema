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
        @path = resolve_path
        @on_evaluators = []
        @maybe_evaluators = []
        @validations = Array(options.fetch(:validate, []))

        resolve_context
        resolve_optional_option
        resolve_omnipresent_option
        resolve_type_system
        resolve_type(type)
        resolve_additional_keys_strategy
        application_class # memoize
        configure(&block) if block_given?
      end

      attr_accessor :name,
        :parent_node,
        :options,
        :type,
        :level,
        :root,
        :additional_keys_strategy

        attr_reader :type_system, :path, :context, :meta, :on_evaluators, :maybe_evaluators, :validations

      # TODO: Can we male this not work with keyword args?!
      def apply(input = MissingInput.new, context = self.context, parent = nil, error_key = nil)
        application_class.new(
          node: self,
          input: input,
          parent: parent,
          context: context,
          error_key: error_key
        ).call
      end

      def build_application(input = MissingInput.new, context = self.context, parent = nil, error_key = nil)
        application_class.new(
          node: self,
          input: input,
          parent: parent,
          context: context,
          error_key: error_key
        )
      end

      def root?
        @is_root
      end

      def optional?
        @optional
      end

      def omnipresent?
        @omnipresent
      end

      def default(value = NxtSchema::MissingInput.new, &block)
        value = value.is_a?(NxtSchema::MissingInput) ? block : value
        condition = ->(input) { input.is_a?(NxtSchema::MissingInput) || input.nil? }
        on(condition, value)

        self
      end

      def on(condition, value = NxtSchema::MissingInput.new, &block)
        value = value.is_a?(NxtSchema::MissingInput) ? block : value
        on_evaluators << OnEvaluator.new(condition: condition, value: value)

        self
      end

      def maybe(value = NxtSchema::MissingInput.new, &block)
        value = value.is_a?(NxtSchema::MissingInput) ? block : value
        maybe_evaluators << MaybeEvaluator.new(value: value)

        self
      end

      def validate(key = NxtSchema::MissingInput.new, *args, &block)
        validator = if key.is_a?(Symbol)
          validator(key, *args)
        elsif key.respond_to?(:call)
          key
        elsif block_given?
          if key.is_a?(NxtSchema::MissingInput)
            block
          else
            configure(&block)
          end
        else
          raise ArgumentError, "Don't know how to resolve validator from: #{key} with: #{args} #{block}"
        end

        register_validator(validator)

        self
      end

      private

      attr_writer :path, :meta, :context, :on_evaluators, :maybe_evaluators

      def validator(key, *args)
        Validators::REGISTRY.resolve!(key).new(*args).build
      end

      def register_validator(validator)
        validations << validator
      end

      def resolve_type(name_or_type)
        @type = root.send(:type_resolver).resolve(type_system, name_or_type)
      end

      def resolve_type_system
        @type_system = TypeSystemResolver.new(node: self).call
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
        @additional_keys_strategy = options.fetch(:additional_keys) { parent_node&.send(:additional_keys_strategy) || :allow }
      end

      def resolve_optional_option
        optional = options.fetch(:optional, false)
        raise Errors::InvalidOptions, 'Optional nodes are only available within schemas' if optional && !parent_node.is_a?(Schema)
        raise Errors::InvalidOptions, "Can't make omnipresent node optional" if optional && omnipresent?

        @optional = optional
      end

      def resolve_omnipresent_option
        omnipresent = options.fetch(:omnipresent, false)
        raise Errors::InvalidOptions, 'Omnipresent nodes are only available within schemas' if omnipresent && !parent_node.is_a?(Schema)
        raise Errors::InvalidOptions, "Can't make omnipresent node optional" if optional? && omnipresent

        @omnipresent = omnipresent
      end

      def resolve_path
        self.path = root? ? name : "#{parent_node.path}.#{name}"
      end

      def resolve_context
        self.context = options.fetch(:context) { parent_node&.send(:context) }
      end
    end
  end
end
