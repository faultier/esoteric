# coding: utf-8

require 'sexp_processor'
require 'llvm'

module Esoteric
  class Compiler < SexpProcessor
    VERSION = '0.0.1'
    ASSIGN_NODES = []

    def init_llvm_module(name)
      @module = LLVM::Module.new(name)
      LLVM::ExecutionEngine.get(@module)
      main_args = LLVM::Type.function(
        LLVM::Type::Int32Ty,
        [LLVM::Type::Int32Ty, LLVM::Type.pointer(LLVM::Type.pointer(LLVM::Type::Int8Ty))]
      )
      @main = @module.get_or_insert_function('main', main_args)
      @main_builder = @main.create_block.builder
    end
  end
end
