# coding: utf-8

require 'logger'

module Esoteric
  class VM
    def self.run(ast, logger=nil)
      new(ast, logger).run
    end

    def initialize(ast, logger=nil)
      @ast = ast
      unless @logger = logger
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::ERROR
      end
    end

    def run
      raise NotImplementedError
    end

    private

    def step
      raise NotImplementedError
    end
  end
end
