# coding: utf-8

module Esoteric
  module Brainfuck
    class Compiler < Esoteric::Compiler::Base
      VERSION = '0.0.1'

      def initialize(src, logger = nil)
        super
        @p   = 0
        @ast = [
          exp_gasgn(:pc, exp_literal(0)),
          exp_gasgn(:tape, [:array]),
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

      def next_token
        @src[@p]
      end

      def process
        exp = case next_token
              when '>' then exp_opgasgn :pc, :+, exp_literal(1)
              when '<' then exp_opgasgn :pc, :+, exp_literal(-1)
              when '+' then
                exp_fcall :set_value, exp_mcall( exp_fcall(:get_value), :+, exp_literal(1))
              when '-' then
                exp_fcall :set_value, exp_mcall( exp_fcall(:get_value), :+, exp_literal(-1))
              when '.' then
                exp_fcall :print, exp_mcall( exp_fcall(:get_value), :chr )
              when ',' then
                exp_fcall :set_value, exp_mcall( exp_fcall(:getc), :ord )
              when '[' then
                @p += 1
                [:until,
                  [:call,
                    [:call, nil,:get_value, [:arglist]],
                    :==,
                    [:arglist, [:lit, 0]]],
                  process_until(lambda { |t| t == ']' }),
                  nil
                ]
              when ']' then raise LoopInterrapt
              end
        @p += 1
        exp
      end
    end
  end
end
