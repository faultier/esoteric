# coding: utf-8

require 'sexp_processor'

module Esoteric
  module DT
    class PreProcessor
      def self.process(ast, is_module = false)
        new(is_module).process(ast)
      end

      def initialize(is_module = false)
      end

      def process(ast)
        Sexp.from_array(ast)
      end
    end
  end
end
