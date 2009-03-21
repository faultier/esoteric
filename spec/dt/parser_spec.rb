require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
require 'esoteric/dt'
$DEBUG = false

DT_EXAMPLES = {
  :push     => 'どどど童貞ちゃうわっ！…',                   # push 1
  :dup      => 'ど…ど',                                     # dup 
  :copy     => 'ど童貞ちゃうわっ！どど童貞ちゃうわっ！ど…', # copy 2
  :discard  => 'ど……',                                      # discard
  :add      => '童貞ちゃうわっ！どどど',                    # add
  :sub      => '童貞ちゃうわっ！どど童貞ちゃうわっ！',      # sub
  :mul      => '童貞ちゃうわっ！どど…',                    # mul
  :div      => '童貞ちゃうわっ！ど童貞ちゃうわっ！ど',      # sub
  :label    => 'ど…ど…どど童貞ちゃうわっ！…ど…ど',          # dup, label t, dup
  :call     => '…ど童貞ちゃうわっ！童貞ちゃうわっ！…',      # call t
  :jump     => '…ど…童貞ちゃうわっ！…',                     # jump t
  :jumpz    => '…童貞ちゃうわっ！ど童貞ちゃうわっ！…',      # jumpz t
  :jumpn    => '…童貞ちゃうわっ！童貞ちゃうわっ！童貞ちゃうわっ！…', # jumpn t
  :return   => '…ど童貞ちゃうわっ！童貞ちゃうわっ！……どど童貞ちゃうわっ！……童貞ちゃうわっ！…', # call t, label t, return
}

DT_MAIN_EXP     = [:define, [:type, :int], :main, [:args, [:type, :int], [:ptype, :p_char]]]
DT_MAIN_RET_EXP = [:block, :return, [:ret, [:lit, 0]]]

describe Esoteric::DT::Parser do
  before :all do
    @parser_class       = Esoteric::DT::Parser
    @preprocessor_class = Esoteric::DT::PreProcessor
    @source             = File.read(File.join($SPEC_DIR.parent, 'examples', 'hi.dt'))
    @parsed_expressions = {
      DT_EXAMPLES[:push]    => [:module, DT_MAIN_EXP.dup + [[:block, :entry, [:call, :'dt.stack_push', [:args, [:lit, 1]]]], DT_MAIN_RET_EXP]],
      DT_EXAMPLES[:dup]     => [:module, DT_MAIN_EXP.dup + [[:block, :entry, [:call, :'dt.stack_dup',  [:args, nil]]], DT_MAIN_RET_EXP]],
      DT_EXAMPLES[:copy]    => [:module, DT_MAIN_EXP.dup + [[:block, :entry, [:call, :'dt.stack_copy', [:args, [:lit, 2]]]], DT_MAIN_RET_EXP]],
      DT_EXAMPLES[:discard] => [:module, DT_MAIN_EXP.dup + [[:block, :entry, [:call, :'dt.stack_pop',  [:args, nil]]], DT_MAIN_RET_EXP]],
      DT_EXAMPLES[:add]     => [:module,
                                 DT_MAIN_EXP.dup +
                                 [
                                   [:block,
                                     :entry,
                                     [:lasgn, :y, [:call, :'dt.stack_pop', [:args, nil]]],
                                     [:lasgn, :x, [:call, :'dt.stack_pop', [:args, nil]]],
                                     [:lasgn, :res, [:binop, :add, [:lvar, :x], [:lvar, :y]]],
                                     [:call, :'dt.stack_push', [:args, [:lvar, :res]]]]
                                   DT_MAIN_RET_EXP
                                 ]
                               ],
      DT_EXAMPLES[:sub]     => [:module,
                                 DT_MAIN_EXP.dup +
                                 [
                                   [:block,
                                     :entry,
                                     [:lasgn, :y, [:call, :'dt.stack_pop', [:args, nil]]],
                                     [:lasgn, :x, [:call, :'dt.stack_pop', [:args, nil]]],
                                     [:lasgn, :res, [:binop, :sub, [:lvar, :x], [:lvar, :y]]],
                                     [:call, :'dt.stack_push', [:args, [:lvar, :res]]]]
                                   DT_MAIN_RET_EXP
                                 ]
                               ],
      DT_EXAMPLES[:mul]     => [:module,
                                 DT_MAIN_EXP.dup +
                                 [
                                   [:block,
                                     :entry,
                                     [:lasgn, :y, [:call, :'dt.stack_pop', [:args, nil]]],
                                     [:lasgn, :x, [:call, :'dt.stack_pop', [:args, nil]]],
                                     [:lasgn, :res, [:binop, :mul, [:lvar, :x], [:lvar, :y]]],
                                     [:call, :'dt.stack_push', [:args, [:lvar, :res]]]]
                                   DT_MAIN_RET_EXP
                                 ]
                               ],
      DT_EXAMPLES[:div]     => [:module,
                                 DT_MAIN_EXP.dup +
                                 [
                                   [:block,
                                     :entry,
                                     [:lasgn, :y, [:call, :'dt.stack_pop', [:args, nil]]],
                                     [:lasgn, :x, [:call, :'dt.stack_pop', [:args, nil]]],
                                     [:lasgn, :res, [:binop, :sdiv, [:lvar, :x], [:lvar, :y]]],
                                     [:call, :'dt.stack_push', [:args, [:lvar, :res]]]]
                                   DT_MAIN_RET_EXP
                                 ]
                               ],
      DT_EXAMPLES[:label]   => [:module,
                                 DT_MAIN_EXP.dup +
                                 [
                                   [:block, :entry, [:call, :'dt.stack_dup',  [:args, nil]]],
                                   [:block, :t, [:call, :'dt.stack_dup',  [:args, nil]]],
                                   DT_MAIN_RET_EXP
                                 ]
                               ],
      DT_EXAMPLES[:call]    => [:module, DT_MAIN_EXP.dup + [[:block, :entry, [:call, :t, [:args, nil]]], DT_MAIN_RET_EXP]],
      DT_EXAMPLES[:jump]    => [:module, DT_MAIN_EXP.dup + [[:block, :entry, [:jump, :t]], DT_MAIN_RET_EXP]],
      DT_EXAMPLES[:jumpz]   => [:module,
                                  DT_MAIN_EXP.dup +
                                  [
                                    [:block, :entry, [:jump, :cb0]],
                                    [:block, :cb0,
                                      [:lasgn, :tv0, [:call, :'dt.stack_pop', [:args, nil]]],
                                      [:lasgn, :cv0, [:op, :icmp_eq, [:lvar, :tv0], [:lit, 0]]],
                                      [:if, [:lvar, :cv0], :t, :bb0]],
                                    [:block, :bb0],
                                    DT_MAIN_RET_EXP
                                  ]
                               ],
      DT_EXAMPLES[:jumpn]   => [:module,
                                  DT_MAIN_EXP.dup +
                                  [
                                    [:block, :entry, [:jump, :cb0]],
                                    [:block, :cb0,
                                      [:lasgn, :tv0, [:call, :'dt.stack_pop', [:args, nil]]],
                                      [:lasgn, :cv0, [:op, :icmp_slt, [:lvar, :tv0], [:lit, 0]]],
                                      [:if, [:lvar, :cv0], :t, :bb0]],
                                    [:block, :bb0],
                                    DT_MAIN_RET_EXP
                                  ]
                               ],
      DT_EXAMPLES[:return]  => [:module,
                                  DT_MAIN_EXP.dup + [[:block, :entry, [:call, :t, [:args, nil]]], DT_MAIN_RET_EXP],
                                  [:define, [:type, :void], :t, [:args, nil], [:block, :entry, [:ret, [:lit, :void]]]]
                               ],
    }
  end

  it_should_behave_like 'parser'

  DT_EXAMPLES.each do |key, code|
    it_should_parse code
  end
end
