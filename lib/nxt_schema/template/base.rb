module NxtSchema
  module Template
    class Base
      def initialize(name:, parent_node:, type: ->(val) { val }, **options, &block)
        resolve_name(name)

        @parent_node = parent_node
        @options = options
        @is_root_node = parent_node.nil?
        @root_node = parent_node.nil? ? self : parent_node.root_node
        @path = resolve_path
        @on_evaluators = []
        @maybe_evaluators = []
        @validations = []
        @configuration = block

        resolve_input_preprocessor
        resolve_output_keys_transformer
        resolve_context
        resolve_optional_option
        resolve_omnipresent_option
        resolve_type_system
        resolve_type(type)
        resolve_additional_keys_strategy
        node_class # memoize
        configure(&block) if block_given?
      end

      attr_accessor :name,
        :parent_node,
        :options,
        :type,
        :root_node,
        :additional_keys_strategy

      attr_reader :type_system,
        :path,
        :context,
        :meta,
        :on_evaluators,
        :maybe_evaluators,
        :validations,
        :configuration,
        :output_keys_transformer,
        :input_preprocessor

      def apply(input: Undefined.new, context: self.context, parent: nil, error_key: nil)
        build_node(input: input, context: context, parent: parent, error_key: error_key).call
      end

      def apply!(input: Undefined.new, context: self.context, parent: nil, error_key: nil)
        result = build_node(input: input, context: context, parent: parent, error_key: error_key).call
        return result if parent

        raise NxtSchema::Errors::Invalid.new(result) if result.errors.any?

        result.output
      end

      def build_node(input: Undefined.new, context: self.context, parent: nil, error_key: nil)
        node_class.new(
          node: self,
          input: preprocess_input(input),
          parent: parent,
          context: context,
          error_key: error_key
        )
      end

      def root_node?
        @is_root_node
      end

      def optional?
        @optional
      end

      def omnipresent?
        @omnipresent
      end

      def typed(type)
        resolve_type(type)

        self
      end

      def default(value = NxtSchema::Undefined.new, &block)
        value = missing_input?(value) ? block : value
        condition = ->(input) { missing_input?(input) || input.nil? }
        on(condition, value)

        self
      end

      def on(condition, value = NxtSchema::Undefined.new, &block)
        value = missing_input?(value) ? block : value
        on_evaluators << OnEvaluator.new(condition: condition, value: value)

        self
      end

      def maybe(value = NxtSchema::Undefined.new, &block)
        value = missing_input?(value) ? block : value
        maybe_evaluators << MaybeEvaluator.new(value: value)

        self
      end

      def validate(key = NxtSchema::Undefined.new, *args, &block)
        # TODO: This does not really work with all kinds of chaining combinations yet!

        validator = if key.is_a?(Symbol)
          validator(key, *args)
        elsif key.respond_to?(:call)
          key
        elsif block_given?
          if key.is_a?(NxtSchema::Undefined)
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

      def validate_with(&block)
        proxy = ->(node) { NxtSchema::Validator::ValidateWithProxy.new(node).validate(&block) }
        register_validator(proxy)
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
        @type = root_node.send(:type_resolver).resolve(type_system, name_or_type)
      end

      def resolve_type_system
        @type_system = TypeSystemResolver.new(node: self).call
      end

      def type_resolver
        @type_resolver ||= begin
          root_node? ? TypeResolver.new : (raise NoMethodError, 'type_resolver is only available on root node')
        end
      end

      def node_class
        @node_class ||= "NxtSchema::Node::#{self.class.name.demodulize}".constantize
      end

      def configure(&block)
        if block.arity == 1
          block.call(self)
        else
          instance_exec(&block)
        end
      end

      def resolve_additional_keys_strategy
        @additional_keys_strategy = options.fetch(:additional_keys) do
          parent_node&.send(:additional_keys_strategy) || :allow
        end
      end

      def resolve_optional_option
        optional = options.fetch(:optional, false)
        raise Errors::InvalidOptions, 'Optional nodes are only available within schemas' if optional && !parent_node.is_a?(Schema)
        raise Errors::InvalidOptions, "Can't make omnipresent node optional" if optional && omnipresent?

        if optional.respond_to?(:call)
          # When a node is conditionally optional we make it optional and add a validator to the parent to check
          # that it's there when the option does not apply.
          optional_node_validator = validator(:optional_node, optional, name)
          parent_node.send(:register_validator, optional_node_validator)
          @optional = true
        else
          @optional = optional
        end
      end

      def resolve_omnipresent_option
        omnipresent = options.fetch(:omnipresent, false)
        raise Errors::InvalidOptions, 'Omnipresent nodes are only available within schemas' if omnipresent && !parent_node.is_a?(Schema)
        raise Errors::InvalidOptions, "Can't make omnipresent node optional" if optional? && omnipresent

        @omnipresent = omnipresent
      end

      def resolve_path
        self.path = root_node? ? name : "#{parent_node.path}.#{name}"
      end

      def resolve_context
        self.context = options.fetch(:context) { parent_node&.send(:context) }
      end

      def missing_input?(value)
        value.is_a? Undefined
      end

      def resolve_input_preprocessor
        @input_preprocessor ||= begin
          if root_node?
            options.key?(:preprocess_input) ? options.fetch(:preprocess_input) : default_input_preprocessor
          else
            options.key?(:preprocess_input) ? options.fetch(:preprocess_input) : parent_node&.input_preprocessor
          end
        end
      end

      def resolve_output_keys_transformer
        @output_keys_transformer = options.fetch(:transform_output_keys) { parent_node&.output_keys_transformer || ->(key) { key.to_sym } }
      end

      def resolve_name(name)
        raise ArgumentError, 'Name can either be a symbol or an integer' unless name.class.in?([Symbol, Integer])

        @name = name
      end

      def preprocess_input(input)
        return input unless input_preprocessor.present?
        input_preprocessor.call(input, self)
      end

      def default_input_preprocessor
        ->(input, node) do
          return input unless node.is_a?(NxtSchema::Template::Schema) && input.respond_to?(:transform_keys)
          input.transform_keys(&:to_sym)
        end
      end
    end
  end
end
