# coding: utf-8

require 'sexp_processor'

module Esoteric
  module DT
    class PreProcessor
      def self.process(ast)
        new.process(ast)
      end

      def initialize
        @runtime = [
          :module,
          [:declare, [:type, :void], :'dt.stack_push', [:args, [:type, :int]]],
          [:declare, [:type, :int], :'dt.stack_pop', [:args, nil]],
          [:declare, [:type, :void], :'dt.stack_dup', [:args, nil]],
          [:declare, [:type, :void], :'dt.stack_copy', [:args, [:type, :int]]],
          [:declare, [:type, :void], :'dt.char_out', [:args, nil]],
          [:declare, [:type, :void], :'dt.num_out', [:args, nil]],
        ]
      end

      def process(ast)
        ast = @runtime + ast[1..-1]
        Sexp.from_array(ast)
      end
    end
  end
end
