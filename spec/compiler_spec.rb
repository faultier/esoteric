require File.expand_path(File.dirname(__FILE__)) + '/spec_helper'
require 'esoteric/compiler'
require 'ruby2ruby'

describe Esoteric::Compiler do
  before :each do
    @compiler = Esoteric::Compiler.new
    @compiler.init_llvm_module 'esoteric'
  end

  it 'should parse gasgn' do
    p sexp = Sexp.from_array([:gasgn, :$p, [:lit, 1]])
    @compiler.process(sexp)
  end
end
