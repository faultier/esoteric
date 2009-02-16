# coding: utf-8

if RUBY_VERSION =~ /^1\.8\./
  $KCODE = 'u'
  require 'jcode'
end

require 'strscan'

module Esoteric
  module Compiler
    class DT < Base
      VERSION = "#{Esoteric::VERSION::SUMMARY}, dt 0.0.1"

      NVAL    = /((?:ど|童貞ちゃうわっ！)+)…/
      LVAL    = NVAL
      PUSH    = /どど#{NVAL}/
      DUP     = /ど…ど/
      COPY    = /ど童貞ちゃうわっ！ど#{NVAL}/
      SWAP    = /ど…童貞ちゃうわっ！/
      DISCARD = /ど……/
      SLIDE   = /ど童貞ちゃうわっ！…#{NVAL}/
      ADD     = /童貞ちゃうわっ！どどど/
      SUB     = /童貞ちゃうわっ！どど童貞ちゃうわっ！/
      MUL     = /童貞ちゃうわっ！どど…/
      DIV     = /童貞ちゃうわっ！ど童貞ちゃうわっ！ど/
      MOD     = /童貞ちゃうわっ！ど童貞ちゃうわっ！童貞ちゃうわっ！/
      HWRITE  = /童貞ちゃうわっ！童貞ちゃうわっ！ど/
      HREAD   = /童貞ちゃうわっ！童貞ちゃうわっ！童貞ちゃうわっ！/
      LABEL   = /…どど#{LVAL}/
      CALL    = /…ど童貞ちゃうわっ！#{LVAL}/
      JUMP    = /…ど…#{LVAL}/
      JUMPZ   = /…童貞ちゃうわっ！ど#{LVAL}/
      JUMPN   = /…童貞ちゃうわっ！童貞ちゃうわっ！#{LVAL}/
      RETURN  = /…童貞ちゃうわっ！…/
      EXIT    = /………/
      COUT    = /童貞ちゃうわっ！…どど/
      NOUT    = /童貞ちゃうわっ！…ど童貞ちゃうわっ！/
      CIN     = /童貞ちゃうわっ！…童貞ちゃうわっ！ど/
      NIN     = /童貞ちゃうわっ！…童貞ちゃうわっ！童貞ちゃうわっ！/

      def initialize(src, logger=nil)
        super
        @s = StringScanner.new(@src)
      end

      private

      def normalize(src)
        normalized = ''
        normalized << $1 while src.sub!(/(ど|童貞ちゃうわっ！|…)/, '*')
        normalized
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
        else raise ::Esoteric::SyntaxError
        end
      end

      def numeric(value)
        raise ArgumentError if "#{value}…" !~ /\A#{NVAL}\z/
        n = value.sub(/\Aど/, '+').
                  sub(/\A童貞ちゃうわっ！/, '-').
                  gsub(/ど/, '0').
                  gsub(/童貞ちゃうわっ！/, '1')
        n.to_i(2)
      end

      def string(value)
        raise ArgumentError if "#{value}…" !~ /\A#{LVAL}\z/
        value.sub(/ど/, '0').sub(/童貞ちゃうわっ！/, '1')
      end
    end
  end
end
