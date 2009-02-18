# coding: utf-8

module Esoteric
  class LoopInterrapt < StandardError; end

  module Compiler
    class Brainfuck < Base
      def initialize(src, logger = nil)
        super
        @p   = 0
        @ast = [:block, [:gasgn, :$pc, [:lit, 0]], [:gasgn, :$tape, [:zarray]]]
        @ast << [:defn, :get_value, [:scope, [:block, [:args], [:op_asgn1, [:gvar, :$tape], [:array, [:gvar, :$pc]], :"||", [:lit, 0]]]]]
        @ast << [:defn, :set_value, [:scope, [:block, [:args, :val], [:attrasgn, [:gvar, :$tape], :[]=, [:array, [:gvar, :$pc], [:lvar, :val]]]]]]
      end

      def compile(optimize = true)
        @ast << process while @p < @src.size
        @ast.compact!
        #       @ast = optimize(@ast) if optimize
        @ast
      end

=begin
      def optimize(source)
        return source unless source.kind_of?(Array)
        optimized = []
        source.each do |exp|
          exp = optimize(exp) if exp.kind_of?(Array) && (exp.first == :block || exp.first == :until || exp.first == :while)
          oplast = optimized.pop
          if oplast.kind_of?(Array) && exp.kind_of?(Array)
            if oplast[0..2].eql?(exp[0..2])
              case
              when exp.first == :op_asgn2
                oplast[4] = [:lit, oplast[4][1] + exp[4][1]]
                exp = nil
              end
            end
          end
          optimized += [oplast, exp].compact
        end
        optimized
      end
=end

      def normalize(src)
        src.gsub(/[^><+-.,\[\]]/, '').split(//)
      end 

      def process
        token = @src[@p]
        exp = case token
              when '>' then [:gasgn, :$pc, [:call, [:gvar, :$pc], :+, [:array, [:lit, 1]]]]
              when '<' then [:gasgn, :$pc, [:call, [:gvar, :$pc], :-, [:array, [:lit, 1]]]]
              when '+' then [:fcall, :set_value, [:array, [:call, [:fcall, :get_value], :+, [:array, [:lit, 1]]]]]
              when '-' then [:fcall, :set_value, [:array, [:call, [:fcall, :get_value], :-, [:array, [:lit, 1]]]]]
              when '.' then [:fcall, :print, [:array, [:call, [:fcall, :get_value], :chr]]]
              when ',' then [:fcall, :set_value, [:array, [:call, [:fcall, :getc], :ord]]]
              when '[' then
                @p += 1
                block = [:block]
                begin 
                  loop do block << process end
                rescue LoopInterrapt
                  #nothing to do
                end
                [:until, [:call, [:fcall, :get_value], :==, [:array, [:lit, 0]]], block, true]
              when ']' then raise LoopInterrapt
              end
        @p += 1
        exp
      end
    end
  end
end
