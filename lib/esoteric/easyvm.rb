# config: utf-8

require 'logger'
require 'ruby2ruby'

module Esoteric
  class EasyVM
    def self.run(ast, logger = nil)
      new(ast, logger).run
    end

    def initialize(ast, logger = nil)
      @ast       = Sexp.from_array(ast)
      @processor = Ruby2Ruby.new
    end

    def run
      # これじゃああんまりにもあんまりなので
      # 抽象構文木を実行できるVMをあとで作る
#     puts code = @processor.process(@ast)
#     eval code
      eval @processor.process(@ast)
    end
  end
end
