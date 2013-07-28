require 'active_support/json/encoding'
require 'sewer/configuration'

module Sewer
  class << self
    def dump(value, *options)
      cache_key = config.cache_key_for.call value, *options

      if cache_key
        config.cache_store.fetch(cache_key) { dump_value(value, *options) }
      else
        dump_value(value, *options)
      end
    end

    private
    def dump_value(value, *options)
      case value
      when Hash
        "{#{value.map { |k,v| "#{dump(k.to_s)}:#{dump(v)}" } * ','}}"
      when Array
        "[#{value.map { |v| dump(v) } * ','}]"
      else
        value.to_json(options)
      end
    end
  end
end