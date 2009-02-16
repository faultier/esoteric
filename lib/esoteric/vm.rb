# coding: utf-8

require 'logger'

module Esoteric
  class ProgramInterrapt < StandardError; end

  class VM
    def self.run(esm, logger=nil)
      new(esm,logger).run
    end

    def initialize(esm, logger=nil)
      @insns    = parse(esm)
      @stack    = []
      @heap     = Hash.new { raise RuntimeError, 'can not read uninitialized heap value' }
      @pc       = 0
      @labels   = {}
      @skip_to  = nil
      @caller   = []
      unless @logger = logger
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::ERROR
      end
    end

    def run
      step while @pc < @insns.size
      raise RuntimeError, ':exit missing'
    rescue ProgramInterrapt => e
      # successfully exit
    end

    private

    def parse(asm)
      asm.split(/\n/).map {|line|
        next unless line =~ /([a-z]+)(?:[\s]+([\w]+))?/
        cmd, arg = $1.intern, $2
        arg ? [cmd, (arg =~ /\A[\d]+\z/ ? arg.to_i : arg)] : [cmd]
      }.compact
    end

    def step
      insn, arg = *@insns[@pc]
#     puts "@pc => #{@pc}, insn => #{insn}, @stack => #{@stack.inspect}, @heap => #{@heap.inspect}, @skip_to => #{@skip_to}, @labels => #{@labels.inspect}, @caller => #{@caller.inspect}"
      if @skip_to.nil? || insn == :label
        case insn
        when :push    then push arg
        when :dup     then value = pop; push value; push value
        when :copy    then push @stack[-arg-1]
        when :swap    then push *[pop, pop]
        when :discard then pop
        when :slide   then top = pop; arg.times { pop }; push top
        when :add     then y, x = pop, pop; push x + y
        when :sub     then y, x = pop, pop; push x - y
        when :mul     then y, x = pop, pop; push x * y
        when :div     then y, x = pop, pop; push (x / y).to_i
        when :mod     then y, x = pop, pop; push x % y
        when :hwrite  then value, address = pop, pop; @heap[address] = value
        when :hread   then address = pop; push @heap[address]
        when :label   then @labels[arg] ||= @pc; @skip_to = nil if @skip_to == arg
        when :call    then @caller.push @pc; jump_to arg
        when :jump    then jump_to arg
        when :jumpz   then jump_to arg if pop == 0
        when :jumpn   then jump_to arg if pop < 0
        when :return  then raise RuntimeError, 'invalid return' if @caller.empty?; @pc = @caller.pop
        when :exit    then raise ProgramInterrapt
        when :cout    then print pop.chr
        when :nout    then print pop
        when :cin     then address = pop; @heap[address] = $stdin.getc.ord
        when :nin     then address = pop; @heap[address] = $stdin.getc.to_i
        end
      end
      @pc += 1
    end

    def push(value)
      @stack.push value
    end

    def pop
      @stack.pop
    end

    def jump_to(label)
      unless @labels[label]
        @skip_to = label
        while @skip_to
          raise RuntimeError, "label '#{label}' is missing" unless @pc < @insns.size
          step
        end
      end
      @pc = @labels[label]
    end
  end
end
