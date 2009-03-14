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

    def self.determin(type)
      eval type.to_s.split('_').map{|w| w.capitalize}.join('')
    end
  end

  class Compiler < SexpProcessor
    VERSION = '0.0.1'

    attr_accessor :module

    def self.compile(sexpr, module_name = 'esoteric', file_name = nil)
      file_name ||= "#{module_nane}.o"
      compiler = new
      compiler.init_llvm_module(module_name)
      compiler.compile(sexpr)
      m.write_bitcode(file_name)
    end

    def initialize
      super
      self.auto_shift_type  = true
      self.strict           = false
      @scope        = nil
      @builder      = nil
      @named_values = Hash.new({})
      @functions    = {}
    end

    def init_llvm_module_with_name(name)
      @module = LLVM::Module.new(name)
      LLVM::ExecutionEngine.get(@module)
    end

    def process(sexp)
#     p sexp
      res = super
#     p res
      return context.empty? ? @module : res
    end

    def process_module(exp)
      process(exp.shift) until exp.empty?
      Sexp.new(@module)
    end

    def process_declare(exp)
      rtype = process(exp.shift).first
      fname = exp.shift
      ftype = LLVM::Type.function(rtype, process(exp.shift).to_a)
      @module.external_function(fname.to_s, ftype)
      Sexp.new(nil)
    end

    def process_define(exp)
      rtype = process(exp.shift).first
      fname = @scope = exp.shift
      ftype = LLVM::Type.function(rtype, process(exp.shift).to_a)
      @functions[fname] = @module.get_or_insert_function(fname.to_s, ftype)
      process(exp.shift) until exp.empty?
      @current_function = nil
      Sexp.new(nil)
    end

    def process_block(exp)
      @builder = @functions[@scope].create_block.builder
      process(exp.shift) until exp.empty?
      @builder = nil
      Sexp.new(nil)
    end

    def process_ret(exp)
      @builder.return(process(exp.shift).first)
      Sexp.new(nil)
    end

    def process_type(exp)
      type = exp.shift
      case type
      when Symbol
        Sexp.new(Type.determin(type))
      when Array, Sexp
        process(type)
      else
        Sexp.new(nil)
      end
    end

    def process_ptr(exp)
      type = process(exp.shift).first
      Sexp.new(LLVM::Type.pointer(type))
    end

    def process_ptype(exp)
      process(Sexp.from_array([:ptr, [:type, exp.shift]]))
    end

    def process_args(exp)
      Sexp.new(*list_exp(exp))
    end

    def process_arg(exp)
      Sexp.new(@functions[@scope].arguments[exp.shift])
    end

    def process_lit(exp)
      case lit = exp.shift
      when Integer
        Sexp.new(lit.llvm)
      when String
        lit = @builder.create_global_string_ptr(lit)
        Sexp.new(lit)
      end
    end

    def process_lasgn(exp)
      name  = exp.shift
      value = process(exp.shift).first
      @named_values[@scope][name] = value
      Sexp.new(nil)
    end

    def process_lvar(exp)
      Sexp.new(@named_values[@scope][exp.shift])
    end

    def process_add(exp)
      rhs1, rhs2 = process(exp.shift).first, process(exp.shift).first
      Sexp.new(@builder.add(rhs1, rhs2))
    end

    private
    def list_exp(exp, ignore_nil = false)
      list = []
      while value = exp.shift
        list << process(value).first
      end
      list.compact! if ignore_nil
      return list
    end
  end
end
