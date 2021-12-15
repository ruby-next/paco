# frozen_string_literal: true

require "monitor"

module Paco
  module Memoizer
    extend MonitorMixin

    class << self
      def memoize(key, &block)
        synchronize do
          @paco_memoized ||= {}
          return @paco_memoized[key] if @paco_memoized.key?(key)

          @paco_memoized[key] = block.call
        end
      end
    end
  end
end
