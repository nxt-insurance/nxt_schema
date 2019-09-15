module NxtSchema
  class Registry
    def initialize
      @store = ActiveSupport::HashWithIndifferentAccess.new
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
      namespaced_store(key).fetch(flat_key(key))
    end

    private

    attr_reader :store

    def namespaced_store(key)
      parts = namespaced_key_parts(key)

      parts[0..-2].inject(store) do |acc, namespace|
        acc.fetch(namespace) do
          acc[namespace] = Registry.new
          acc = acc[namespace]
          acc
        end
      end
    end

    def namespaced_key_parts(key)
      key.downcase.split('::')
    end

    def flat_key(key)
      namespaced_key_parts(key).last
    end

    def ensure_key_not_registered_already(key)
      return unless namespaced_store(key).key?(flat_key(key))

      raise KeyError, "Key: #{flat_key(key)} already registered in #{namespaced_store(key)}"
    end
  end
end
