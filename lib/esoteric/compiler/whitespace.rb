# coding: utf-8

require 'strscan'

module Esoteric
  module Compiler
    class Whitespace < Base
      VERSION = '0.0.2'

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

      def compile(do_optimize = false)
        begin
          loop do
            exp = process
            next unless !!exp
            if exp.first == :defn
              @ast.unshift exp
            else
              @ast.push exp
            end
          end
        rescue ProcessInterrapt
          # do nothing
        end
        @ast.unshift :block
#       require 'pp'; pp @ast
        @ast = optimize(@ast) if do_optimize
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
        when @s.scan(SLIDE)   then
          exp_block exp_lasgn(:top, exp_gvarcall(:stack, :pop)), exp_mcall(exp_literal(numeric(@s[1])), :times, exp_pop), exp_push(exp_lvar(:top))
        when @s.scan(ADD)     then
          exp_block exp_lasgn(:y, exp_pop), exp_lasgn(:x, exp_pop), exp_mcallpush(exp_lvar(:x), :+, exp_lvar(:y))
        when @s.scan(SUB)     then
          exp_block exp_lasgn(:y, exp_pop), exp_lasgn(:x, exp_pop), exp_mcallpush(exp_lvar(:x), :-, exp_lvar(:y))
        when @s.scan(MUL)     then
          exp_block exp_lasgn(:y, exp_pop), exp_lasgn(:x, exp_pop), exp_mcallpush(exp_lvar(:x), :*, exp_lvar(:y))
        when @s.scan(DIV)     then
          exp_block exp_lasgn(:y, exp_pop), exp_lasgn(:x, exp_pop), exp_mcallpush(exp_lvar(:x), :/, exp_lvar(:y))
        when @s.scan(MOD)     then
          exp_block exp_lasgn(:y, exp_pop), exp_lasgn(:x, exp_pop), exp_mcallpush(exp_lvar(:x), :%, exp_lvar(:y))
        when @s.scan(HWRITE)  then
          exp_block exp_lasgn(:val, exp_pop), exp_lasgn(:addr, exp_pop), exp_gvarcall(:heap, :[]=, exp_lvar(:addr), exp_lvar(:val))
        when @s.scan(HREAD)   then
          exp_block exp_lasgn(:addr, exp_pop), exp_push(exp_gvarcall(:heap, :[], exp_lvar(:addr)))
        when @s.scan(LABEL)   then
          defn(string(@s[1]).intern) { process_until( lambda {|*args| @s.eos? || !!@s.match?(RETURN)} ) }
        when @s.scan(CALL)    then exp_fcall(string(@s[1]).intern)
        when @s.scan(JUMP)
          exp_if exp_literal(true), exp_fcall(string(@s[1]).intern), process_until( lambda {|*args| @s.eos? || !!@s.match?(RETURN)} )
        when @s.scan(JUMPZ)
          exp_if exp_mcall(pop, :==, exp_literal(0)), exp_fcall(string(@s[1]).intern), process_until( lambda {|*args| @s.eos? || !!@s.match?(RETURN)} )
        when @s.scan(JUMPN)
          exp_if exp_mcall(pop, :<, exp_literal(0)), exp_fcall(string(@s[1]).intern), process_until( lambda {|*args| @s.eos? || !!@s.match?(RETURN)} )
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

      def exp_push(value)
        exp_gvarcall :stack, :push, value
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
