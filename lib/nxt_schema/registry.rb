module NxtSchema
  class Registry
    def initialize(namespace_separator: '::', namespace: '')
      @store = ActiveSupport::HashWithIndifferentAccess.new
      @namespace_separator = namespace_separator
      @namespace = namespace
    end

    delegate_missing_to :store

    # register('strict::string')
    # Registry[:strict].register

    def register(key, value)
      key = key.to_s
      ensure_key_not_registered_already(key)
      namespaced_store(key)[flat_key(key)] = value
    end

    def resolve(key, *args)
      value = resolve_value(key)
      return value unless value.respond_to?(:call)

      value.call(*args)
    end

    def resolve_value(key)
      key = key.to_s
      parts = namespaced_key_parts(key)[0..-2]

      namespaced_store = parts.inject(store) do |acc, key|
        acc.fetch(key)
      rescue KeyError
        raise KeyError, "No registry found at #{key} in #{acc}"
      end

      begin
        namespaced_store.fetch(flat_key(key))
      rescue KeyError
        raise KeyError, "Could not find #{flat_key(key)} in #{namespaced_store}"
      end
    end

    private

    attr_reader :store, :namespace_separator, :namespace

    def namespaced_store(key)
      parts = namespaced_key_parts(key)

      current_parts = []

      parts[0..-2].inject(store) do |acc, namespace|
        current_parts << namespace
        current_namespace = current_parts.join(namespace_separator)

        acc.fetch(namespace) do
          acc[namespace] = Registry.new(namespace: current_namespace)
          acc = acc[namespace]
          acc
        end
      end
    end

    def namespaced_key_parts(key)
      key.downcase.split(namespace_separator)
    end

    def flat_key(key)
      namespaced_key_parts(key).last
    end

    def ensure_key_not_registered_already(key)
      return unless namespaced_store(key).key?(flat_key(key))

      raise KeyError, "Key: #{flat_key(key)} already registered in #{namespaced_store(key)}"
    end

    def to_s
      identifier = 'NxtSchema::Registry'
      identifier << "#{namespace_separator}#{namespace}" unless namespace.blank?
      identifier
    end
  end
end
