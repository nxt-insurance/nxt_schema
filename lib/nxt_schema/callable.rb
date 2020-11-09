module NxtSchema
  class Callable
    def initialize(callable, target = nil, *args)
      @callable = callable
      @target = target
      @args = args
    end

    def call
      return callable if value?
      return callable.call(*args_from_arity) if proc?

      target.send(callable, *args_from_arity)
    end

    private

    attr_reader :callable, :target, :args

    def method?
      @method ||= callable.class.in?([Symbol, String]) && target.respond_to?(callable)
    end

    def proc?
      @proc ||= callable.respond_to?(:call)
    end

    def value?
      !method? && !proc?
    end

    def arity
      proc? ? callable.arity : 0
    end

    def args_from_arity
      @args_from_arity ||= ([target] + args).take(arity)
    end
  end
end
