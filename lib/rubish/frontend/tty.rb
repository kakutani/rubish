# frozen_string_literal: true

require 'reline'

module Rubish
  module Frontend
    # Default frontend: runs in a real terminal via Reline. The original
    # rubish behavior, extracted into a Frontend so other hosts (e.g.
    # an in-process Echoes embedding) can swap the I/O surface out.
    class Tty < Base
      # Reline.readline gained the `rprompt:` keyword argument in a
      # specific version; older Relines only accept the positional
      # `(prompt, add_to_history = false)` form. Detect once.
      RELINE_SUPPORTS_RPROMPT =
        Reline::Core.instance_method(:readline).parameters.any? { |_, n| n == :rprompt }

      def read_line(prompt:, rprompt: nil)
        if RELINE_SUPPORTS_RPROMPT
          Reline.readline(prompt: prompt, rprompt: rprompt || '')
        else
          Reline.readline(prompt, false)
        end
      end

      def read_continuation_line(prompt)
        Reline.readline(prompt, false)
      end

      def read_simple_line(prompt = '')
        Reline.readline(prompt, false)
      end

      def insert_text(text)
        return if Reline.pre_input_hook
        Reline.pre_input_hook = -> {
          Reline.insert_text(text)
          Reline.pre_input_hook = nil
        }
      end

      def setup_completion(&block)
        Reline.completion_proc = block
      end
    end
  end
end
