require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
require 'esoteric/dt'
$DEBUG = false

DT_EXAMPLES = {
  :push     => 'どどど童貞ちゃうわっ！…',                   # push 1
  :dup      => 'ど…ど',                                     # dup 
  :copy     => 'ど童貞ちゃうわっ！どど童貞ちゃうわっ！ど…', # copy 2
  :discard  => 'ど……',                                      # discard
  :label    => '…どど童貞ちゃうわっ！…',                    # label t
  :jump     => '…ど…童貞ちゃうわっ！…',                     # jump t
  :jumpz    => '…童貞ちゃうわっ！ど童貞ちゃうわっ！…',      # jumpz t
  :jumpn    => '…童貞ちゃうわっ！童貞ちゃうわっ！童貞ちゃうわっ！…', # jumpn t
}

describe Esoteric::DT::Parser do
  before :all do
    @parser_class       = Esoteric::DT::Parser
    @preprocessor_class = Esoteric::DT::PreProcessor
    @source             = File.read(File.join($SPEC_DIR.parent, 'examples', 'hi.dt'))
    @parsed_expressions = {
      DT_EXAMPLES[:push]    => [[:block, :entry, [:call, :'dt.stack_push', [:args, [:lit, 1]]]]],
      DT_EXAMPLES[:dup]     => [[:block, :entry, [:call, :'dt.stack_dup',  [:args, nil]]]],
      DT_EXAMPLES[:copy]    => [[:block, :entry, [:call, :'dt.stack_copy', [:args, [:lit, 2]]]]],
      DT_EXAMPLES[:discard] => [[:block, :entry, [:call, :'dt.stack_pop',  [:args, nil]]]],
      DT_EXAMPLES[:label]   => [[:block, :t]],
      DT_EXAMPLES[:jump]    => [[:block, :entry, [:jump, :t]]],
      DT_EXAMPLES[:jumpz]   => [
                                  [:block, :entry, [:jump, :cb0]],
                                  [:block, :cb0,
                                    [:lasgn, :tv0, [:call, :'dt.stack_pop', [:args, nil]]],
                                    [:lasgn, :cv0, [:op, :icmp_eq, [:lvar, :tv0], [:lit, 0]]],
                                    [:if, [:lvar, :cv0], :t, :bb0]],
                                  [:block, :bb0]
                               ],
      DT_EXAMPLES[:jumpn]   => [
                                  [:block, :entry, [:jump, :cb0]],
                                  [:block, :cb0,
                                    [:lasgn, :tv0, [:call, :'dt.stack_pop', [:args, nil]]],
                                    [:lasgn, :cv0, [:op, :icmp_slt, [:lvar, :tv0], [:lit, 0]]],
                                    [:if, [:lvar, :cv0], :t, :bb0]],
                                  [:block, :bb0]
                               ],
    }
  end

  it_should_behave_like 'parser'

  DT_EXAMPLES.each do |key, code|
    it_should_parse code
  end
end
