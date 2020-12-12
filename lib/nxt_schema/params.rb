module NxtSchema
  module Params
    module ClassMethods
      def nxt_params
        @nxt_params ||= NxtSchema::Params::Proxy.new(self)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
