# coding: utf-8

require 'sexp_processor'
require 'llvm'

module Esoteric
  module Type
    Void      = LLVM::Type::VoidTy
    Int       = LLVM::Type::Int32Ty
    Long      = LLVM::Type::Int64Ty
    Char      = LLVM::Type::Int8Ty
    PChar     = LLVM::Type.pointer(Char)
  end

  class Compiler < SexpProcessor
    VERSION = '0.0.1'

    def self.compile(sexpr, module_name = 'esoteric', file_name = nil)
      file_name ||= "#{module_nane}.o"
      compiler = new
      compiler.init_llvm_module(module_name)
      compiler.compile(sexpr)
      m.write_bitcode(file_name)
    end

    def initialize
      super
      self.auto_shift_type = true
      self.strict = false
    end

    def init_llvm_module(module_name = 'esoteric')
      @module= LLVM::Module.new(module_name)
      LLVM::ExecutionEngine.get(@module)

      @printf  = @module.external_function(
        'printf',
        LLVM::Type.function(Type::Int, [Type::PChar], true)
      )
      @sprintf = @module.external_function(
        'sprintf',
        LLVM::Type.function(Type::PChar, [Type::PChar, Type::PChar], true)
      )
    end

    def process(sexp)
      p sexp
      res = super
      return context.empty? ? @module : res
    end

    def process_main(exp)
      context.push @module.get_or_insert_function(
        'main',
        LLVM::Type.function(Type::Int, [Type::Int, LLVM::Type.pointer(Type::PChar)])
      )
      process(exp.shift).shift.return(0.llvm)
      Sexp.new(context.pop)
    end

=begin
    def process_type(exp)
      type = exp.shift
      case type
      when :int
        Sexp.new(Type::Int)
      when :char
        Sexp.new(Type::Char)
      end
    end

    def process_ptr(exp)
      type = process(exp.shift)
      Sexp.new(LLVM::Type.pointer(type.shift))
    end
=end

    def process_lit(exp)
      case lit = exp.shift
      when Integer, Bignum
        Sexp.new(lit.llvm)
      end
    end

    def process_defn(exp)
      name  = exp.shift
      ret   = process(exp.shift).first
      args  = process(exp.shift).to_a

      ftype = LLVM::Type.function(ret, *args)
      func  = @module.get_or_insert_function(name.to_s, ftype)

      context.unshift func
      block = process(exp.shift)
      context.shift

      Sexp.new(nil)
    end

    def process_args(exp)
      types = []
      while e = exp.shift
        types << process(e)
      end
      Sexp.new(types.map {|e| e.shift })
    end

    def process_block(exp)
      func = context.find {|c| c.is_a?(LLVM::Function)}
      context.unshift func.create_block.builder
      until exp.empty?
        bexp = exp.shift
        process(bexp) if !!bexp
      end
      Sexp.new(context.shift)
    end
  end
end
