require 'datadog/instrumentation/hook_point'
require 'datadog/instrumentation/hook_point_error'
require 'datadog/instrumentation/strategy/prepend'
require 'datadog/instrumentation/strategy/chain'

module Datadog
  module Instrumentation
    # Represents a target in which to inject a hook
    class HookPoint
      DEFAULT_STRATEGY = Module.respond_to?(:prepend) ? :prepend : :chain

      class << self
        def parse(hook_point)
          klass_name, separator, method_name = hook_point.split(/(\#|\.)/, 2)

          raise ArgumentError, hook_point if klass_name.nil? || separator.nil? || method_name.nil?
          raise ArgumentError, hook_point unless ['.', '#'].include?(separator)

          method_kind = separator == '.' ? :klass_method : :instance_method

          [klass_name.to_sym, method_kind, method_name.to_sym]
        end

        def const_exist?(name)
          resolve_const(name) && true
        rescue NameError, ArgumentError
          false
        end

        def resolve_const(name)
          raise ArgumentError if name.nil? || name.empty?

          name.to_s.split('::').inject(Object) { |a, e| a.const_get(e, false) }
        end

        def strategy_module(strategy)
          case strategy
          when :prepend then Strategy::Prepend
          when :chain then Strategy::Chain
          else
            raise HookPointError, "unknown strategy: #{strategy.inspect}"
          end
        end
      end

      attr_reader :klass_name, :method_kind, :method_name

      def initialize(hook_point, strategy = DEFAULT_STRATEGY)
        @klass_name, @method_kind, @method_name = HookPoint.parse(hook_point)
        @strategy = strategy

        extend HookPoint.strategy_module(strategy)
      end

      def to_s
        @to_s ||= "#{@klass_name}#{@method_kind == :instance_method ? '#' : '.'}#{@method_name}"
      end

      def exist?
        return false unless HookPoint.const_exist?(@klass_name)

        if klass_method?
          (
            klass.singleton_class.public_instance_methods(false) +
            klass.singleton_class.protected_instance_methods(false) +
            klass.singleton_class.private_instance_methods(false)
          ).include?(@method_name)
        elsif instance_method?
          (
            klass.public_instance_methods(false) +
            klass.protected_instance_methods(false) +
            klass.private_instance_methods(false)
          ).include?(@method_name)
        else
          raise HookPointError, "#{self} unknown hook point kind"
        end
      end

      def klass
        HookPoint.resolve_const(@klass_name)
      end

      def klass_method?
        @method_kind == :klass_method
      end

      def instance_method?
        @method_kind == :instance_method
      end

      def private_method?
        if klass_method?
          klass.private_methods.include?(@method_name)
        elsif instance_method?
          klass.private_instance_methods.include?(@method_name)
        else
          raise HookPointError, "#{self} unknown hook point kind"
        end
      end

      def protected_method?
        if klass_method?
          klass.protected_methods.include?(@method_name)
        elsif instance_method?
          klass.protected_instance_methods.include?(@method_name)
        else
          raise HookPointError, "#{self} unknown hook point kind"
        end
      end

      # rubocop:disable Lint/UselessMethodDefinition
      def installed?(key)
        super
      end

      def install(key, &block)
        return unless exist?
        return if installed?(key)

        super
      end

      def uninstall(key)
        return unless exist?
        return unless installed?(key)

        super
      end

      def enable(key)
        super
      end

      def disable(key)
        super
      end

      def disabled?(key)
        super
      end
      # rubocop:enable Lint/UselessMethodDefinition
    end
  end
end
