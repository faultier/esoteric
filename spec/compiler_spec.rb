require File.expand_path(File.dirname(__FILE__)) + '/spec_helper'
require 'esoteric/compiler'

describe Esoteric::Compiler do
  before :all do
    @module_name = 'esoteric'
  end

  before :each do
    system "#{@module_name}.o" if test(?e, "#{@module_name}.o")
  end

  before :each do
    @compiler = Esoteric::Compiler.new
    @compiler.init_llvm_module(@module_name)
  end

  it 'should parse entry expression' do
    sexp = Sexp.from_array([:main, [:block, nil]])
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
    m.get_function('main').get_basic_block_list.should_not be_empty
  end

  it 'should parse function expression' do
    p sexp = Sexp.from_array([:defn, :dummy, [:args, nil], [:block, nil]])
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
    m.get_function('dummy').get_basic_block_list.should_not be_empty
  end
end
