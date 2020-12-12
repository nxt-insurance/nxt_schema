module NxtSchema
  module Registry
    module ClassMethods
      def schemas
        @schemas ||= NxtSchema::Registry::Proxy.new(self)
      end

      def inherited(subclass)
        schemas.each do |key, schema|
          subclass.schemas.register(key, schema)
        end

        super
      end
    end

    def self.included(base)
      base.extend(ClassMethods)

      delegate :schemas, to: :class
    end
  end
end
