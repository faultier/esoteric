# coding: utf-8

require 'sexp_processor'

module Esoteric
  module DT
    class PreProcessor < Esoteric::PreProcessor
      def requires
        [
          [
            [:declare, [:type, :void], :'dt.stack_push', [:args, [:type, :int]]],
            [:declare, [:type, :int], :'dt.stack_pop', [:args, nil]],
            [:declare, [:type, :void], :'dt.stack_dup', [:args, nil]],
            [:declare, [:type, :void], :'dt.stack_copy', [:args, [:type, :int]]],
            [:declare, [:type, :void], :'dt.char_out', [:args, nil]],
            [:declare, [:type, :void], :'dt.num_out', [:args, nil]],
          ],
          ['dt_runtime']
        ]
      end
    end
  end
end
