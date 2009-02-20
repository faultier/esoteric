# coding: utf-8

require 'logger'

module Esoteric
  class ProcessInterrapt < StandardError; end
  class LoopInterrapt < StandardError; end

  class Parser
    def self.parse(src, logger = nil)
      new(src, logger).parse
    end

    def initialize(src, logger = nil)
      @src    = normalize(src)
      @ast    = []
      unless @logger = logger
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::ERROR
      end
    end

    def parse
      while exp = process
        if exp.first == :defn
          @ast.unshift exp
        else
          @ast.push exp
        end
      end
      @ast.unshift :block
      @ast
    end

    private 

    def normalize(src)
      src
    end

    def next_token
      nil
    end

    def process
      next_token
    end

    def process_until(terminate_expr)
      block = [:block]
      begin
        until terminate_expr.call(next_token)
          block << process 
          break if block.last.nil?
        end
      rescue LoopInterrapt
      end
      block
    end

    def exp_arglist(args=[])
      _arglist = [:arglist]
      _arglist += args unless args.empty?
      _arglist
    end

    def exp_defn_arglist(args=[])
      _arglist = [:args]
      _arglist += args unless args.empty?
      _arglist
    end

    def exp_defn(name, *args)
      [:defn, name, [:scope, [:block, exp_defn_arglist(args), yield]]]
    end

    def exp_mcall(receiver, name, *args)
      [:call, receiver, name, exp_arglist(args)]
    end

    def exp_fcall(name, *args)
      exp_mcall(nil, name, *args)
    end

    def exp_variable(scope, name)
      [scope, name]
    end

    def exp_gvar(name)
      exp_variable :gvar, "$#{name}".intern
    end

    def exp_gvarcall(name, *args)
      exp_mcall exp_gvar(name), *args
    end

    def exp_lvar(name)
      exp_variable :lvar, name
    end

    def exp_lvarcall(name, *args)
      exp_mcall exp_lvar(name), *args
    end

    def exp_assign(scope, name, value)
      [scope, name, value]
    end

    def exp_gasgn(name, value)
      exp_assign :gasgn, "$#{name}".intern, value
    end

    def exp_opgasgn(name, operator, value)
      exp_gasgn name, exp_gvarcall(name, operator, value)
    end

    def exp_lasgn(name, value)
      exp_assign :lasgn, name, value
    end

    def exp_oplasgn(name, operator, value)
      exp_lasgn name, exp_lvarcall(name, operator, value)
    end

    def exp_literal(value)
      [:lit, value]
    end

    def exp_condition(name, cond, tblock, fblock=nil)
      [name, cond, tblock, fblock]
    end

    def exp_if(cond, tblock, fblock=nil)
      exp_condition :if, cond, tblock, fblock
    end

    def exp_block(*args)
      [:block, *args]
    end

    def numeric(value)
      value.to_i
    end

    def string(value)
      value.to_s
    end
  end
end
