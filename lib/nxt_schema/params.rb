module NxtSchema
  module Params
    module ClassMethods
      def nxt_params
        @nxt_params ||= NxtSchema::Params::Proxy.new(self)
      end

      def inherited(subclass)
        nxt_params.each do |key, schema|
          subclass.nxt_params.register(key, schema)
        end

        super
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
