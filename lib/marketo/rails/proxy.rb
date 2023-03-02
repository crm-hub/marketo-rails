module Marketo
  module Rails
    module Proxy
      def self.included(base)
        base.class_eval do
          include Adapters::AdapterProxy

          def self.settings(options = {}, &block)
            @settings ||= Marketo::Rails::Settings.new(options)

            @settings.update_options(options) unless options.empty?

            if block_given?
              @settings.instance_eval(&block)
              return self
            end

            @settings
          end

          def self.__marketo__
            @__marketo__ ||= @settings.sync_object::ClassMethods.new(self)
          end

          def __marketo__
            @__marketo__ ||= self.class.settings.sync_object::InstanceMethods.new(self)
          end
        end
      end
    end
  end
end
