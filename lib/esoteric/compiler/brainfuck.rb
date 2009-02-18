# coding: utf-8

module Esoteric
  class LoopInterrapt < StandardError; end

  module Compiler
    class Brainfuck < Base
      VERSION = '0.0.1'

      def initialize(src, logger = nil)
        super
        @p   = 0
        @ast = [
          [:gasgn, :$pc, [:lit, 0]],
          [:gasgn, :$tape, [:array]],
          [:defn, :get_value,
            [:scope,
              [:block,
                [:args],
                [:op_asgn1,
                  [:gvar, :$tape],
                  [:arglist,
                    [:gvar, :$pc]],
                    :"||",
                    [:lit, 0]]]]],
          [:defn, :set_value,
            [:scope,
              [:block,
                [:args, :val],
                [:call,
                  [:gvar, :$tape],
                  :[]=,
                  [:arglist,
                    [:gvar, :$pc],
                    [:lvar, :val]]]]]]
        ]
      end

      def normalize(src)
        src.gsub(/[^><+-.,\[\]]/, '').split(//)
      end 

      def process
        exp = case @src[@p]
              when '>' then [:gasgn, :$pc, [:call, [:gvar, :$pc], :+, [:arglist, [:lit, 1]]]]
              when '<' then [:gasgn, :$pc, [:call, [:gvar, :$pc], :-, [:arglist, [:lit, 1]]]]
              when '+' then [:call, nil, :set_value, [:arglist, [:call, [:call, nil, :get_value, [:arglist]], :+, [:arglist, [:lit, 1]]]]]
              when '-' then [:call, nil, :set_value, [:arglist, [:call, [:call, nil, :get_value, [:arglist]], :-, [:arglist, [:lit, 1]]]]]
              when '.' then [:call, nil, :print, [:arglist, [:call, [:call, nil, :get_value, [:arglist]], :chr, [:arglist]]]]
              when ',' then [:call, nil, :set_value, [:arglist, [:call, [:call, nil, :getc, [:arglist]], :ord, [:arglist]]]]
              when '[' then
                @p += 1
                block = [:block]
                begin 
                  loop { block << process }
                rescue LoopInterrapt
                  #nothing to do
                end
                [:until, [:call, [:call, nil, :get_value, [:arglist]], :==, [:arglist, [:lit, 0]]], block, true]
              when ']' then raise LoopInterrapt
              end
        @p += 1
        exp
      end
    end
  end
end
