# frozen_string_literal: true

module Rubish
  # The I/O surface the shell sees: where it reads lines from, where it
  # writes characters to, how it surfaces completions. The default
  # `Frontend::Tty` wraps Reline and stdin/stdout. Alternate frontends
  # (e.g. an in-process embedding inside a GUI terminal) bypass the TTY
  # entirely and feed the shell input via direct method calls.
  module Frontend
    # Abstract base. Subclasses override at minimum `read_line`.
    class Base
      # Read one line from the user. Returns a String on success or nil
      # on EOF (e.g. Ctrl-D in a TTY).
      def read_line(prompt:, rprompt: nil)
        raise NotImplementedError
      end

      # Continuation prompt inside a multi-line command (PS2). Defaults to
      # plain `read_line` if a frontend has nothing special to do.
      def read_continuation_line(prompt)
        read_line(prompt: prompt)
      end

      # Simple, no-completion line read for builtins like `read`.
      def read_simple_line(prompt = '')
        read_line(prompt: prompt)
      end

      # Pre-fill the next `read_line` invocation with `text` so the user
      # can edit/submit it. Used for typeahead injection during slow
      # startup, command expansion, and "edit the previous command".
      # Default: no-op; override if the frontend supports it.
      def insert_text(_text); end

      # Register a completion callback. The block receives the current
      # input String and returns an Array of candidate Strings. Default
      # no-op; override if the frontend supports completion.
      def setup_completion(&_block); end
    end
  end
end

require_relative 'frontend/tty'
