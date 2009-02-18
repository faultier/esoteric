# coding: utf-8

require 'logger'
require 'sexp_processor'

module Esoteric
  module Compiler
    class Base
      def self.compile(src, optimize = false, logger = nil)
        new(src, logger).compile
      end

      def initialize(src, logger = nil)
        @src    = normalize(src)
        @ast    = []
        unless @logger = logger
          @logger = Logger.new(STDOUT)
          @logger.level = Logger::ERROR
        end
      end

      def compile(optimize = false)
        while exp = process
          if exp.first == :defn
            @ast.unshift exp
          else
            @ast.push exp
          end
        end
        @ast.unshift :block
        p @ast
        Sexp.from_array(@ast)
      end

      private 

      def normalize(src)
        src
      end

      def process
        nil
      end

      def numeric(value)
        value.to_i
      end

      def string(value)
        value.to_s
      end
    end
  end
end
