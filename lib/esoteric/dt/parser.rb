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
      ADD     = /童貞ちゃうわっ！どどど/ # not yet
      SUB     = /童貞ちゃうわっ！どど童貞ちゃうわっ！/ # not yet
      MUL     = /童貞ちゃうわっ！どど…/ # not yet
      DIV     = /童貞ちゃうわっ！ど童貞ちゃうわっ！ど/ # not yet
      MOD     = /童貞ちゃうわっ！ど童貞ちゃうわっ！童貞ちゃうわっ！/ # not yet
      HWRITE  = /童貞ちゃうわっ！童貞ちゃうわっ！ど/ # not yet
      HREAD   = /童貞ちゃうわっ！童貞ちゃうわっ！童貞ちゃうわっ！/ # not yet
      LABEL   = /…どど#{LVAL}/
      CALL    = /…ど童貞ちゃうわっ！#{LVAL}/
      JUMP    = /…ど…#{LVAL}/
      JUMPZ   = /…童貞ちゃうわっ！ど#{LVAL}/
      JUMPN   = /…童貞ちゃうわっ！童貞ちゃうわっ！#{LVAL}/
      RETURN  = /…童貞ちゃうわっ！…/ # not yet
      EXIT    = /………/ # not yet
      COUT    = /童貞ちゃうわっ！…どど/ # not yet
      NOUT    = /童貞ちゃうわっ！…ど童貞ちゃうわっ！/ # not yet
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
        normalized = ''
        normalized << $1 while src.sub!(/(ど|童貞ちゃうわっ！|…)/, '*')
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
#       when @s.scan(SWAP)    then exp_push exp_pop, exp_pop
        when @s.scan(DISCARD) then [:call, :'dt.stack_pop', [:args, nil]]
#       when @s.scan(SLIDE)
#         exp_block { |block|
#           block << exp_lasgn(:top, exp_gvarcall(:stack, :pop))
#           block << exp_iterator(exp_mcall(exp_literal(numeric(@s[1])), :times)) {|internal| internal << exp_pop}
#           block << exp_push(exp_lvar(:top))
#         }
#       when @s.scan(ADD)
#         exp_block { |block|
#           block << exp_lmasgn([:y, :x], [exp_pop, exp_pop])
#           block << exp_mcallpush(exp_lvar(:x), :+, exp_lvar(:y))
#         }
#       when @s.scan(SUB)
#         exp_block { |block|
#           block << exp_lmasgn([:y, :x], [exp_pop, exp_pop])
#           block << exp_mcallpush(exp_lvar(:x), :-, exp_lvar(:y))
#         }
#       when @s.scan(MUL)
#         exp_block { |block|
#           block << exp_lmasgn([:y, :x], [exp_pop, exp_pop])
#           block << exp_mcallpush(exp_lvar(:x), :*, exp_lvar(:y))
#         }
#       when @s.scan(DIV)
#         exp_block { |block|
#           block << exp_lmasgn([:y, :x], [exp_pop, exp_pop])
#           block << exp_mcallpush(exp_lvar(:x), :/, exp_lvar(:y))
#         }
#       when @s.scan(MOD)
#         exp_block { |block|
#           block << exp_lmasgn([:y, :x], [exp_pop, exp_pop])
#           block << exp_mcallpush(exp_lvar(:x), :%, exp_lvar(:y))
#         }
#       when @s.scan(HWRITE)
#         exp_block { |block|
#           block << exp_lmasgn([:val, :addr], [exp_pop, exp_pop])
#           block << exp_attribute_assign(exp_gvar(:heap), :[]=, exp_lvar(:addr), exp_lvar(:val))
#         }
#       when @s.scan(HREAD)
#         exp_block { |block|
#           block << exp_lasgn(:addr, exp_pop)
#           block << exp_push(exp_gvarcall(:heap, :[], exp_lvar(:addr)))
#         }
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
          p current_function.reject
          p current_block
          nil
#       when @s.scan(EXIT)    then exp_fcall :exit, exp_literal(0)
#       when @s.scan(COUT)    then exp_gvarcall :stdout, :print, exp_mcall(exp_pop, :chr)
#       when @s.scan(NOUT)    then exp_gvarcall :stdout, :print, exp_mcall(exp_pop, :to_i)
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
