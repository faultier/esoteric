# coding: utf-8

require 'sexp_processor'

module Esoteric
  module DT
    class PreProcessor
      def self.process(ast, is_module = false)
        new(is_module).process(ast)
      end

      def initialize(is_module = false)
        @is_module = is_module
        @ast = [
          :module,
          [:declare, [:type, :void], :'dt.stack_push', [:args, [:type, :int]]],
          [:declare, [:type, :int], :'dt.stack_pop', [:args, nil]],
          [:declare, [:type, :void], :'dt.stack_dup', [:args, nil]],
          [:declare, [:type, :void], :'dt.stack_copy', [:args, [:type, :int]]]
        ]
      end

      def process(ast)
        if @is_module
          @ast.push(ast)
        else
          @ast.push(
            [:define,
              [:type, :int],
              :main,
              [:args,
                [:type, :int],
                [:ptype, :p_char]],
              *ast 
            ]
          )
        end
        Sexp.from_array(@ast)
      end
    end
  end
end
