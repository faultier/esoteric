require File.expand_path(File.dirname(__FILE__)) + '/spec_helper'

MAIN_FUNC_EXP = [:define, [:type, :int], :main, [:args, [:type, :int], [:type, :p_char]]]

describe Esoteric::Compiler do
  before :all do
    @module_name = 'compiler'
  end

# before :each do
#   system "rm #{@module_name}.bc" if test(?e, "#{@module_name}.bc")
# end

  before :each do
    @compiler = Esoteric::Compiler.new
    @compiler.init_llvm_module_with_name(@module_name)
  end

  it 'should process declare expression' do
    sexp = Sexp.from_array([:declare, [:type, :void], :puts, [:args, [:ptype, :p_char]]])
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
    m.should satisfy { m.inspect =~ /declare void @puts\(i8\*\*\)/ }
#   p m
  end

  it 'should process define expression' do
    sexp = Sexp.from_array([:define, [:type, :int], :dummy, [:args, nil], [:block, [:ret, [:lit, 0]]]])
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
    m.should satisfy { m.inspect =~ /define i32 @dummy\(\)/ }
#   p m
  end

  it 'should process string literal' do
    sexp = Sexp.from_array([:define, [:type, :p_char], :greeting, [:args, nil], [:block, [:ret, [:lit, 'Hi!']]]])
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
    m.should satisfy { m.inspect =~ /internal constant \[4 x i8\] c"Hi!\\00"/ }
    m.should satisfy { m.inspect =~ /ret i8\* getelementptr \(\[4 x i8\]\* @0, i32 0, i32 0\)/ }
#   p m
  end

  it 'should process local variable expression' do
    block = [:block, [:lasgn, :res, [:add, [:lit, 2], [:lit, 1]]], [:ret, [:lvar, :res]]]
    sexp = Sexp.from_array(MAIN_FUNC_EXP.dup.push(block))
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
#   p m
  end

  it 'should process argument expression' do
    block = [:block, [:ret, [:arg, 0]]]
    sexp = Sexp.from_array(MAIN_FUNC_EXP.dup.push(block))
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
    m.should satisfy { m.inspect =~ /ret i32 %0/ }
#   p m
  end
end
