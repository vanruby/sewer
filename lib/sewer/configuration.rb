require 'sewer/cache'

module Sewer
  module Configuration
    class Configurator
      def initialize(&block)
        self.instance_eval(&block) if block
      end

      def option(key, default = nil)
        define_singleton_method key do
          instance_variable_get "@#{key}"
        end

        define_singleton_method "#{key}=" do |value|
          instance_variable_set "@#{key}", value
        end

        self.send "#{key}=", default
      end

      def block_option(key, &default_block)
        define_singleton_method key do |&block|
          if block
            instance_variable_set "@#{key}", block
          else
            instance_variable_get "@#{key}"
          end
        end

        self.send key, &default_block
      end
    end
  end

  def self.config(&block)
    @config ||= Configuration::Configurator.new do
      # config.cache_store
      #   where to store the fragments
      #   defaults to an in-memory cache

      option :cache_store, Cache::MemoryStore.new

      # config.cache_key_for
      #   given a value object and the options passed to dump, return
      #   a cache key for the value object
      #   by default this uses the cache_key method on the value object

      block_option :cache_key_for do |value, *options|
        options.empty? && value.respond_to?(:cache_key) ? Cache.expand_cache_key(value, 'sewer') : nil
      end
    end

    @config.instance_eval(&block) if block

    @config
  end
end    