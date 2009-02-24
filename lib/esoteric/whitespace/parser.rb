# coding: utf-8

require 'strscan'

module Esoteric
  module Whitespace
    class Parser < Esoteric::Parser
      NVAL    = /([ \t]+)\n/
      LVAL    = NVAL
      PUSH    = /  #{NVAL}/
      DUP     = / \n /
      COPY    = / \t #{NVAL}/
      SWAP    = / \n\t/
      DISCARD = / \n\n/
      SLIDE   = / \t\n#{NVAL}/
      ADD     = /\t   /
      SUB     = /\t  \t/
      MUL     = /\t  \n/
      DIV     = /\t \t /
      MOD     = /\t \t\t/
      HWRITE  = /\t\t /
      HREAD   = /\t\t\t/
      LABEL   = /\n  #{LVAL}/
      CALL    = /\n \t#{LVAL}/
      JUMP    = /\n \n#{LVAL}/
      JUMPZ   = /\n\t #{LVAL}/
      JUMPN   = /\n\t\t#{LVAL}/
      RETURN  = /\n\t\n/
      EXIT    = /\n\n\n/
      COUT    = /\t\n  /
      NOUT    = /\t\n \t/
      CIN     = /\t\n\t /
      NIN     = /\t\n\t\t/

      def initialize(src,logger=nil)
        super
        @s = StringScanner.new(@src)
        @ast = [
          [:gasgn, :$stack, [:array]],
          [:gasgn, :$heap, [:hash]],
        ]
      end

      def parse
        begin
          loop do
            exp = process
            @ast.push exp if !!exp
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
        src.gsub(/[^ \t\n]/, '')
      end

      def process
        case
        when @s.eos?          then raise ProcessInterrapt
        when @s.scan(PUSH)    then exp_push exp_literal(numeric(@s[1]))
        when @s.scan(DUP)     then exp_push exp_gvarcall(:stack, :last)
        when @s.scan(COPY)    then exp_push exp_gvarcall(:stack, :[], exp_literal(-(numeric(@s[1]))-1))
        when @s.scan(SWAP)    then exp_push exp_pop, exp_pop
        when @s.scan(DISCARD) then exp_pop
        when @s.scan(SLIDE)
          exp_block { |block|
            block << exp_lasgn(:top, exp_gvarcall(:stack, :pop))
            block << exp_iterator(exp_mcall(exp_literal(numeric(@s[1])), :times)) {|internal| internal << exp_pop}
            block << exp_push(exp_lvar(:top))
          }
        when @s.scan(ADD)
          exp_block { |block|
            block << exp_lmasgn([:y, :x], [exp_pop, exp_pop])
            block << exp_mcallpush(exp_lvar(:x), :+, exp_lvar(:y))
          }
        when @s.scan(SUB)
          exp_block { |block|
            block << exp_lmasgn([:y, :x], [exp_pop, exp_pop])
            block << exp_mcallpush(exp_lvar(:x), :-, exp_lvar(:y))
          }
        when @s.scan(MUL)
          exp_block { |block|
            block << exp_lmasgn([:y, :x], [exp_pop, exp_pop])
            block << exp_mcallpush(exp_lvar(:x), :*, exp_lvar(:y))
          }
        when @s.scan(DIV)
          exp_block { |block|
            block << exp_lmasgn([:y, :x], [exp_pop, exp_pop])
            block << exp_mcallpush(exp_lvar(:x), :/, exp_lvar(:y))
          }
        when @s.scan(MOD)
          exp_block { |block|
            block << exp_lmasgn([:y, :x], [exp_pop, exp_pop])
            block << exp_mcallpush(exp_lvar(:x), :%, exp_lvar(:y))
          }
        when @s.scan(HWRITE)
          exp_block { |block|
            block << exp_lmasgn([:val, :addr], [exp_pop, exp_pop])
            block << exp_attribute_assign(exp_gvar(:heap), :[]=, exp_lvar(:addr), exp_lvar(:val))
          }
        when @s.scan(HREAD)
          exp_block { |block|
            block << exp_lasgn(:addr, exp_pop)
            block << exp_push(exp_gvarcall(:heap, :[], exp_lvar(:addr)))
          }
        when @s.scan(LABEL)
          exp_defn(string(@s[1]).intern) { process_until( lambda {|*args| @s.eos? || !!@s.match?(RETURN)} ) }
        when @s.scan(CALL)
          exp_fcall string(@s[1]).intern
        when @s.scan(JUMP)
          exp_if [:true], exp_fcall(string(@s[1]).intern), process_until( lambda {|*args| @s.eos? || !!@s.match?(RETURN)} )
        when @s.scan(JUMPZ)
          exp_if exp_mcall(exp_pop, :==, exp_literal(0)), exp_fcall(string(@s[1]).intern), process_until( lambda {|*args| @s.eos? || !!@s.match?(RETURN)} )
        when @s.scan(JUMPN)
          exp_if exp_mcall(exp_pop, :<, exp_literal(0)), exp_fcall(string(@s[1]).intern), process_until( lambda {|*args| @s.eos? || !!@s.match?(RETURN)} )
        when @s.scan(RETURN)  then nil
        when @s.scan(EXIT)    then exp_fcall :exit, exp_literal(0)
        when @s.scan(COUT)    then exp_gvarcall :stdout, :print, exp_mcall(exp_pop, :chr)
        when @s.scan(NOUT)    then exp_gvarcall :stdout, :print, exp_mcall(exp_pop, :to_i)
        when @s.scan(CIN)     then exp_mcallpush exp_gvarcall(:stdin, :getc), :ord
        when @s.scan(NIN)     then exp_mcallpush exp_gvarcall(:stdin, :getc), :to_i
        else raise SyntaxError
        end
      end

      def exp_pop
        exp_gvarcall :stack, :pop
      end

      def exp_push(*value)
        exp_gvarcall :stack, :push, *value
      end

      def exp_mcallpush(receiver, method, *args)
        exp_push exp_mcall(receiver, method, *args)
      end

      def numeric(value)
        raise ArgumentError if "#{value}\n" !~ /\A#{NVAL}\z/
        n = value.sub(/\A /, '+').
                  sub(/\A\t/, '-').
                  gsub(/ /, '0').
                  gsub(/\t/, '1')
        n.to_i(2)
      end

      def string(value)
        raise ArgumentError if "#{value}\n" !~ /\A#{LVAL}\z/
        value.gsub(/ /, 's').gsub(/\t/, 't')
      end
    end
  end
end
