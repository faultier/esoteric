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
    sexp = Sexp.from_array([:define, [:type, :int], :dummy, [:args, nil], [:block, :entry, [:ret, [:lit, 0]]]])
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
    m.should satisfy { m.inspect =~ /define i32 @dummy\(\)/ }
#   p m
  end

  it 'should process string literal' do
    sexp = Sexp.from_array([:define, [:type, :p_char], :greeting, [:args, nil], [:block, :entry, [:ret, [:lit, 'Hi!']]]])
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
    m.should satisfy { m.inspect =~ /internal constant \[4 x i8\] c"Hi!\\00"/ }
    m.should satisfy { m.inspect =~ /ret i8\* getelementptr \(\[4 x i8\]\* @0, i32 0, i32 0\)/ }
#   p m
  end

  it 'should process local variable expression' do
    block = [:block, :entry, [:lasgn, :res, [:binop, :add, [:lit, 2], [:lit, 1]]], [:ret, [:lvar, :res]]]
    sexp = Sexp.from_array(MAIN_FUNC_EXP.dup.push(block))
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
#   p m
  end

  it 'should process argument expression' do
    block = [:block, :entry, [:ret, [:arg, 0]]]
    sexp = Sexp.from_array(MAIN_FUNC_EXP.dup.push(block))
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
    m.should satisfy { m.inspect =~ /ret i32 %0/ }
#   p m
  end

  it 'should process call expression' do
    sexp = Sexp.from_array(
      [:module,
        [:declare, [:type, :void], :puts, [:args, [:type, :p_char]]],
        [:define,
          [:type, :int],
          :main,
          [:args,
            [:type, :int],
            [:ptype, :p_char]],
          [:block,
            :entry,
            [:call, :puts, [:args, [:lit, 'Hi!']]],
            [:ret, [:lit, 0]]]]]
    )
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
    m.should satisfy { m.inspect =~ /call void @puts/ }
#   p m
  end

  it 'should process calculate expression' do
    block = [:block, :entry]
    block << [:lasgn, :res, [:binop, :add, [:arg, 0], [:lit, 1]]]
    block << [:lasgn, :res, [:binop, :sub, [:lvar, :res], [:lit, 1]]]
    block << [:lasgn, :res, [:binop, :mul, [:lvar, :res], [:lit, 1]]]
    block << [:lasgn, :res, [:binop, :sdiv, [:lvar, :res], [:lit, 1]]]
    block << [:ret, [:lvar, :res]]
    sexp = Sexp.from_array(MAIN_FUNC_EXP.dup.push(block))
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
    m.should satisfy { m.inspect =~ /%2 = add i32 %0, 1/ }
    m.should satisfy { m.inspect =~ /%3 = sub i32 %2, 1/ }
    m.should satisfy { m.inspect =~ /%4 = mul i32 %3, 1/ }
    m.should satisfy { m.inspect =~ /%5 = sdiv i32 %4, 1/ }
    m.should satisfy { m.inspect =~ /ret i32 %5/ }
#   p m
  end

  it 'should process compare expression' do
    block = [:block, :entry]
    block << [:lasgn, :cond, [:op, :icmp_eq, [:arg, 0], [:lit, 1]]]
    block << [:ret, [:arg, 0]]
    sexp = Sexp.from_array(MAIN_FUNC_EXP.dup.push(block))
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
#   p m
    m.should be_kind_of(LLVM::Module)
  end

  it 'should process jump expression' do
    main = MAIN_FUNC_EXP.dup
    main << [:block, :entry, [:jump, :return]]
    main << [:block, :error, [:ret, [:lit, 1]]]
    main << [:block, :return, [:ret, [:lit, 0]]]
    sexp = Sexp.from_array(main)
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
    m.should satisfy { m.inspect =~ /br label %return/ }
#   p m
  end

  it 'should process if expression' do
    main = MAIN_FUNC_EXP.dup
    main << [:block, :entry, [:lasgn, :cond, [:op, :icmp_eq, [:arg, 0], [:lit, 0]]], [:if, [:lvar, :cond], :return, :error]]
    main << [:block, :error, [:ret, [:lit, 1]]]
    main << [:block, :return, [:ret, [:lit, 0]]]
    sexp = Sexp.from_array(main)
    m = nil
    lambda { m = @compiler.process(sexp) }.should_not raise_error
    m.should be_kind_of(LLVM::Module)
    m.should satisfy { m.inspect =~ /br i1 %2, label %return, label %error/ }
#   p m
  end
end
