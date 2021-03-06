require 'datadog/instrumentation/hook_point_error'

module Datadog
  module Instrumentation
    module Strategy
      # Injects hooks by method rewriting
      module Chain
        def installed?(key)
          defined(key)
        end

        def install(key, &block)
          define(key, &block)
          chain(key)
        end

        def uninstall(key)
          disable(key)
          remove(key)
        end

        def enable(key)
          chain(key)
        end

        def disable(key)
          unchain(key)
        end

        def disabled?(key)
          !chained?(key)
        end

        private

        def defined(suffix)
          if klass_method?
            (
              klass.methods \
              + klass.protected_methods \
              + klass.private_methods
            ).include?(:"#{method_name}_with_#{suffix}")
          elsif instance_method?
            (
              klass.instance_methods \
              + klass.protected_instance_methods \
              + klass.private_instance_methods
            ).include?(:"#{method_name}_with_#{suffix}")
          else
            # TODO: Change output to logger
            puts "[#{Process.pid}] #{self} unknown hook point kind"
            raise HookPointError, "#{self} unknown hook point kind"
          end
        end

        def define(suffix, &block)
          hook_point = self
          method_name = @method_name

          if klass_method?
            klass.singleton_class.instance_eval do
              if hook_point.private_method?
                private
              elsif hook_point.protected_method?
                protected
              else
                public
              end

              define_method(:"#{method_name}_with_#{suffix}", &block)
            end
          elsif instance_method?
            klass.class_eval do
              if hook_point.private_method?
                private
              elsif hook_point.protected_method?
                protected
              else
                public
              end

              define_method(:"#{method_name}_with_#{suffix}", &block)
            end
          else
            raise HookPointError, 'unknown hook point kind'
          end
        end

        def remove(suffix)
          method_name = @method_name

          if klass_method?
            klass.singleton_class.instance_eval do
              remove_method(:"#{method_name}_with_#{suffix}")
            end
          elsif instance_method?
            klass.class_eval do
              remove_method(:"#{method_name}_with_#{suffix}")
            end
          else
            raise HookPointError, 'unknown hook point kind'
          end
        end

        def chained?(suffix)
          method_name = @method_name

          if klass_method?
            klass.singleton_class.instance_eval do
              instance_method(:"#{method_name}").original_name == :"#{method_name}_with_#{suffix}"
            end
          elsif instance_method?
            klass.class_eval do
              instance_method(:"#{method_name}").original_name == :"#{method_name}_with_#{suffix}"
            end
          else
            raise HookPointError, 'unknown hook point kind'
          end
        end

        def chain(suffix)
          method_name = @method_name

          if klass_method?
            klass.singleton_class.instance_eval do
              alias_method :"#{method_name}_without_#{suffix}", :"#{method_name}"
              alias_method :"#{method_name}", :"#{method_name}_with_#{suffix}"
            end
          elsif instance_method?
            klass.class_eval do
              alias_method :"#{method_name}_without_#{suffix}", :"#{method_name}"
              alias_method :"#{method_name}", :"#{method_name}_with_#{suffix}"
            end
          else
            raise HookPointError, 'unknown hook point kind'
          end
        end

        def unchain(suffix)
          method_name = @method_name

          if klass_method?
            klass.singleton_class.instance_eval do
              alias_method :"#{method_name}", :"#{method_name}_without_#{suffix}"
            end
          elsif instance_method?
            klass.class_eval do
              alias_method :"#{method_name}", :"#{method_name}_without_#{suffix}"
            end
          end
        end

        if RUBY_VERSION < '3.0'
          def apply(obj, suffix, *args, &block)
            obj.send("#{method_name}_without_#{suffix}", *args, &block)
          end
        else
          def apply(obj, suffix, *args, **kwargs, &block)
            obj.send("#{method_name}_without_#{suffix}", *args, **kwargs, &block)
          end
        end
      end
    end
  end
end
