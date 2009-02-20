# coding: utf-8

if RUBY_VERSION =~ /^1\.8\./
  $KCODE = 'u'
  require 'jcode'
end

require 'strscan'

module Esoteric
  module Tetete
    class Parser < Esoteric::Parser
      def initialize(src, logger = nil)
        super
        @s = StringScanner.new(@src)
        @ast = [
          exp_gasgn(:P, exp_literal(0)),
          exp_gasgn(:B, [:array]),
          exp_defn(:get_value) {
            [:op_asgn1, exp_gvar(:B), exp_arglist([exp_gvar(:P)]), :"||", exp_literal(0)]
          },
          exp_defn(:set_value, :val) { exp_gvarcall(:B, :[]=, exp_gvar(:P), exp_lvar(:val)) }
        ]
      end

      def parse
        begin
          loop do
            exp = process
            next unless !!exp
            case exp.first
            when :defn  then @ast.unshift exp
            when :block then @ast += exp[1..-1]
            else             @ast.push exp
            end
          end
        rescue ProcessInterrapt
          # do nothing
        end
        @ast.unshift :block
#       require 'pp'; pp @ast
        @ast
      end

      private

      def normalize(src)
        src.gsub! /\{.*\}/, ''
        src
      end

      def process
        case
        when @s.eos?
          raise ProcessInterrapt
        when @s.scan(/ー(.+?)てー/m)
          @s[1].split(//).inject([:block]) { |block, c| 
            block << exp_fcall(:set_value, exp_literal(c))
            block << exp_opgasgn(:P, :+, exp_literal(1))
          }
        when @s.scan(/ててー/)
          exp_fcall :set_value, exp_mcall(exp_fcall(:get_value), :+, exp_literal(1))
        when @s.scan(/てっー/)
          exp_fcall :set_value, exp_mcall(exp_fcall(:get_value), :+, exp_literal(-1))
        when @s.scan(/てってー/)
          exp_opgasgn :P, :+, exp_literal(1)
        when @s.scan(/てっててー/)
          exp_opgasgn :P, :+, exp_literal(-1)
        when @s.scan(/てってっー/)
          [:block, exp_fcall(:print, exp_fcall(:get_value)), exp_opgasgn(:P, :+, exp_literal(1))]
        when @s.scan(/てってってー/)
          [:block, exp_fcall(:set_value, exp_fcall(:getc)), exp_opgasgn(:P, :+, exp_literal(1))]
        when @s.scan(/てってっててー/)
          [:until,
            exp_mcall(exp_fcall(:get_value), :==, exp_literal(0)),
            process_until(lambda { |*args| @s.eos? || !!@s.match?(/てってってっー/) }),
            nil
          ]
        when @s.scan(/てってってっー/)
          raise LoopInterrapt
        when @s.scan(/.[^てっー]*/m)
          nil
        end
      end
    end
  end
end
