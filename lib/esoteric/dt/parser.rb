# coding: utf-8

if RUBY_VERSION =~ /^1\.8\./
  $KCODE = 'u'
  require 'jcode'
end

require 'strscan'

module Esoteric
  module DT
    class Parser < Esoteric::Parser
      NVAL    = /((?:ど|童貞ちゃうわっ！)+)…/
      LVAL    = NVAL
      PUSH    = /どど#{NVAL}/
      DUP     = /ど…ど/
      COPY    = /ど童貞ちゃうわっ！ど#{NVAL}/
      SWAP    = /ど…童貞ちゃうわっ！/ # not yet
      DISCARD = /ど……/
      SLIDE   = /ど童貞ちゃうわっ！…#{NVAL}/ # not yet
      ADD     = /童貞ちゃうわっ！どどど/
      SUB     = /童貞ちゃうわっ！どど童貞ちゃうわっ！/
      MUL     = /童貞ちゃうわっ！どど…/
      DIV     = /童貞ちゃうわっ！ど童貞ちゃうわっ！ど/
      MOD     = /童貞ちゃうわっ！ど童貞ちゃうわっ！童貞ちゃうわっ！/ # not yet
      HWRITE  = /童貞ちゃうわっ！童貞ちゃうわっ！ど/ # not yet
      HREAD   = /童貞ちゃうわっ！童貞ちゃうわっ！童貞ちゃうわっ！/ # not yet
      LABEL   = /…どど#{LVAL}/
      CALL    = /…ど童貞ちゃうわっ！#{LVAL}/
      JUMP    = /…ど…#{LVAL}/
      JUMPZ   = /…童貞ちゃうわっ！ど#{LVAL}/
      JUMPN   = /…童貞ちゃうわっ！童貞ちゃうわっ！#{LVAL}/
      RETURN  = /…童貞ちゃうわっ！…/
      EXIT    = /………/
      COUT    = /童貞ちゃうわっ！…どど/
      NOUT    = /童貞ちゃうわっ！…ど童貞ちゃうわっ！/
      CIN     = /童貞ちゃうわっ！…童貞ちゃうわっ！ど/ # not yet
      NIN     = /童貞ちゃうわっ！…童貞ちゃうわっ！童貞ちゃうわっ！/ # not yet

      def initialize(src, logger=nil)
        super
        @s        = StringScanner.new(@src)
        @ast      = [:module]
      end

      def parse
        exp = nil
        begin
          loop do
            next unless exp = process
            case 
            when exp.respond_to?(:first) && (exp.first == :define || exp.first == :declare)
              @ast.push exp
              @current_function = exp if exp.first == :define
            when exp.respond_to?(:first) && exp.first == :block
              current_function.push exp
            else
              current_block.push exp
            end
          end
        rescue ProcessInterrapt
          # do nothing
        end
        if @main_function
          ifnone = lambda { main_function.push [:block, :return, [:ret, [:lit, 0]]] }
          main_function.find(ifnone) { |exp| exp.respond_to?(:[]) && exp[0] == :block && exp[1] == :return }
        end
#       require 'pp'; pp @ast
        @ast
      end


      private

      def normalize(src)
        source = src.dup
        normalized = ''
        normalized << $1 while source.sub!(/(ど|童貞ちゃうわっ！|…)/, '*')
        normalized
      end

      def main_function
        @main_function ||= [:define, [:type, :int], :main, [:args, [:type, :int], [:ptype, :p_char]]]
      end

      def current_function
        unless !!@current_function
          @ast << @current_function = main_function
        end
        @current_function
      end

      def current_block
        block = current_function.reverse.find { |exp| exp.respond_to?(:first) && exp.first == :block }
        unless !!block
          current_function << block = [:block, :entry]
        end
        block
      end

      def process
        case
        when @s.eos?          then raise ProcessInterrapt
        when @s.scan(PUSH)    then [:call, :'dt.stack_push', [:args, [:lit, numeric(@s[1])]]]
        when @s.scan(DUP)     then [:call, :'dt.stack_dup', [:args, nil]]
        when @s.scan(COPY)    then [:call, :'dt.stack_copy', [:args, [:lit, numeric(@s[1])]]]
        when @s.scan(SWAP)    then raise NotImplementedError, 'SWAP'
        when @s.scan(DISCARD) then [:call, :'dt.stack_pop', [:args, nil]]
        when @s.scan(SLIDE)   then raise NotImplementedError, 'SLIDE'
        when @s.scan(ADD)
          current_block.push [:lasgn, :y, [:call, :'dt.stack_pop', [:args, nil]]]
          current_block.push [:lasgn, :x, [:call, :'dt.stack_pop', [:args, nil]]]
          current_block.push [:lasgn, :res, [:binop, :add, [:lvar, :x], [:lvar, :y]]]
          [:call, :'dt.stack_push', [:args, [:lvar, :res]]]
        when @s.scan(SUB)
          current_block.push [:lasgn, :y, [:call, :'dt.stack_pop', [:args, nil]]]
          current_block.push [:lasgn, :x, [:call, :'dt.stack_pop', [:args, nil]]]
          current_block.push [:lasgn, :res, [:binop, :sub, [:lvar, :x], [:lvar, :y]]]
          [:call, :'dt.stack_push', [:args, [:lvar, :res]]]
        when @s.scan(MUL)
          current_block.push [:lasgn, :y, [:call, :'dt.stack_pop', [:args, nil]]]
          current_block.push [:lasgn, :x, [:call, :'dt.stack_pop', [:args, nil]]]
          current_block.push [:lasgn, :res, [:binop, :mul, [:lvar, :x], [:lvar, :y]]]
          [:call, :'dt.stack_push', [:args, [:lvar, :res]]]
        when @s.scan(DIV)
          current_block.push [:lasgn, :y, [:call, :'dt.stack_pop', [:args, nil]]]
          current_block.push [:lasgn, :x, [:call, :'dt.stack_pop', [:args, nil]]]
          current_block.push [:lasgn, :res, [:binop, :sdiv, [:lvar, :x], [:lvar, :y]]]
          [:call, :'dt.stack_push', [:args, [:lvar, :res]]]
        when @s.scan(MOD)     then raise NotImplementedError, 'MOD'
        when @s.scan(HWRITE)  then raise NotImplementedError, 'HWRITE'
        when @s.scan(HREAD)   then raise NotImplementedError, 'HREAD'
        when @s.scan(LABEL)   then [:block, string(@s[1]).intern]
        when @s.scan(CALL)    then [:call, string(@s[1]).intern, [:args, nil]]
        when @s.scan(JUMP)    then [:jump, string(@s[1]).intern]
        when @s.scan(JUMPZ)
          i, j, k, l = 0, 0, 0, 0
          i += 1 while current_function.any? { |b| b.respond_to?(:[]) && b[1] == "cb#{i}".intern }
          j += 1 while current_function.any? { |b| b.respond_to?(:[]) && !!b[2] && b[2].any? { |e| e.respond_to?(:[]) && e[0] == :lasgn && e[1] == "tv#{j}".intern } }
          k += 1 while current_function.any? { |b| b.respond_to?(:[]) && !!b[2] && b[2].any? { |e| e.respond_to?(:[]) && e[0] == :lasgn && e[1] == "cv#{k}".intern } }
          l += 1 while current_function.any? { |b| b.respond_to?(:[]) && b[1] == "bb#{l}".intern }
          cb, tv, cv, rb = "cb#{i}".intern, "tv#{j}".intern, "cv#{k}".intern, "bb#{l}".intern
          current_block.push [:jump, cb]
          current_function.push [:block,
            cb,
            [:lasgn, tv, [:call, :'dt.stack_pop', [:args, nil]]],
            [:lasgn, cv, [:op, :icmp_eq, [:lvar, tv], [:lit, 0]]],
            [:if, [:lvar, cv], string(@s[1]).intern, rb]
          ]
          [:block, rb]
        when @s.scan(JUMPN)
          i, j, k, l = 0, 0, 0, 0
          i += 1 while current_function.any? { |b| b.respond_to?(:[]) && b[1] == "cb#{i}".intern }
          j += 1 while current_function.any? { |b| b.respond_to?(:[]) && !!b[2] && b[2].any? { |e| e.respond_to?(:[]) && e[0] == :lasgn && e[1] == "tv#{j}".intern } }
          k += 1 while current_function.any? { |b| b.respond_to?(:[]) && !!b[2] && b[2].any? { |e| e.respond_to?(:[]) && e[0] == :lasgn && e[1] == "cv#{k}".intern } }
          l += 1 while current_function.any? { |b| b.respond_to?(:[]) && b[1] == "bb#{l}".intern }
          cb, tv, cv, rb = "cb#{i}".intern, "tv#{j}".intern, "cv#{k}".intern, "bb#{l}".intern
          current_block.push [:jump, cb]
          current_function.push [:block,
            cb,
            [:lasgn, tv, [:call, :'dt.stack_pop', [:args, nil]]],
            [:lasgn, cv, [:op, :icmp_slt, [:lvar, tv], [:lit, 0]]],
            [:if, [:lvar, cv], string(@s[1]).intern, rb]
          ]
          [:block, rb]
        when @s.scan(RETURN)
          cb, label = current_block, current_block[1]
          current_function.delete_if {|b| b == cb }
          cb[1] = :entry
          cb.push [:ret, [:lit, :void]]
          func = [:define, [:type, :void], label, [:args, nil], cb]
          func
        when @s.scan(EXIT)    then
          current_function[2] == :main ? [:jump, :return] : nil
        when @s.scan(COUT)    then [:call, :'dt.char_out', [:args, nil]]
        when @s.scan(NOUT)    then [:call, :'dt.number_out', [:args, nil]]
#       when @s.scan(CIN)     then exp_mcallpush exp_gvarcall(:stdin, :getc), :ord
#       when @s.scan(NIN)     then exp_mcallpush exp_gvarcall(:stdin, :getc), :to_i
        else raise SyntaxError
        end
      end

      def exp_pop
        [:call, :'dt.stack_pop', [:args, nil]]
      end

      def exp_push(value)
        [:call, :'dt.stack_push', [:args, value]]
      end

      def exp_mcallpush(receiver, method, *args)
        exp_push exp_mcall(receiver, method, *args)
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
        value.gsub(/ど/, 'd').gsub(/童貞ちゃうわっ！/, 't')
      end
    end
  end
end
