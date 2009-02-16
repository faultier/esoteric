# coding: utf-8

require 'strscan'

module Esoteric
  module Compiler
    class Whitespace < Base
      VERSION = "#{Esoteric::VERSION::SUMMARY}, whitespace 0.0.1"

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
      end

      private

      def normalize(src)
        src.gsub(/[^ \t\n]/, '')
      end

      def step
        case
        when @s.eos?          then nil
        when @s.scan(PUSH)    then command :push,   @s[1]
        when @s.scan(DUP)     then command :dup
        when @s.scan(COPY)    then command :copy,   @s[1]
        when @s.scan(SWAP)    then command :swap
        when @s.scan(DISCARD) then command :discard
        when @s.scan(SLIDE)   then command :slide,  @s[1]
        when @s.scan(ADD)     then command :add
        when @s.scan(SUB)     then command :sub
        when @s.scan(MUL)     then command :mul
        when @s.scan(DIV)     then command :div
        when @s.scan(MOD)     then command :mod
        when @s.scan(HWRITE)  then command :hwrite
        when @s.scan(HREAD)   then command :hread
        when @s.scan(LABEL)   then command :label,  @s[1]
        when @s.scan(CALL)    then command :call,   @s[1]
        when @s.scan(JUMP)    then command :jump,   @s[1]
        when @s.scan(JUMPZ)   then command :jumpz,  @s[1]
        when @s.scan(JUMPN)   then command :jumpn,  @s[1]
        when @s.scan(RETURN)  then command :return
        when @s.scan(EXIT)    then command :exit
        when @s.scan(COUT)    then command :cout
        when @s.scan(NOUT)    then command :nout
        when @s.scan(CIN)     then command :cin
        when @s.scan(NIN)     then command :nin
        else raise SyntaxError
        end
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
        value.gsub(/ /, '0').gsub(/\t/, '1')
      end
    end
  end
end
