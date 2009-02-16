# coding: utf-8

require 'logger'

module Esoteric
  module Compiler
    class Base
      def self.compile(src, logger=nil)
        new(src, logger).compile
      end

      def initialize(src, logger=nil)
        @src = normalize(src)
        unless @logger = logger
          @logger = Logger.new(STDOUT)
          @logger.level = Logger::ERROR
        end
      end

      def compile
        insns = []
        while st = step
          insns.push st
        end
        insns.map {|c,a| a.nil? ? c.to_s : "#{c}\t#{a}"}.join("\n")
      end

      private 

      def normalize(src)
        src
      end

      def step
        nil
      end

      def command(name, arg=nil)
        case name
        when :push,:copy,:slide               then [name, numeric(arg)]
        when :label,:call,:jump,:jumpz,:jumpn then [name, string(arg)]
        when :dup,:swap,:discard              then [name]
        when :add,:sub,:mul,:div,:mod         then [name]
        when :hwrite,:hread                   then [name]
        when :return,:exit                    then [name]
        when :cout,:nout,:cin,:nin            then [name]
        else raise SyntaxError
        end
      end

      def numeric(value)
        value.to_i
      end

      def string(value)
        value.to_s
      end
    end
  end
end
