# coding: utf-8

require 'logger'

module Esoteric
  class Runner
    def self.run(source, compiler, vm, options={}, logger=nil)
      logger ||= Logger.new(STDOUT)
      logger.level = options[:loglevel] if !!options[:loglevel]
      if options[:interactive]
        raise NotImplementedError
      else
        esm = !!compiler ? compiler.compile(source) : source
        if options[:checkonly]
          puts 'Syntax OK'
        else
          vm.run esm, logger
        end
      end
    end
  end
end

if defined?(ESOTERIC_BIN_VERSION)
  require 'optparse'
  $source   = nil
  $options  = {}
  OptionParser.new {|opt|
    opt.on('-e EXPR') {|v| $source = v }
    opt.on('-i','--interactive') { $options[:interactive] = true }
    opt.on('-c','--check-only') { $options[:checkonly] = true }
    opt.on('-d','--debug') { $options[:loglevel] = Logger::DEBUG }
    opt.on('-w','--warning') { $options[:loglevel] ||= Logger::WARN }
    opt.on('-v','--version') { puts ESOTERIC_BIN_VERSION; exit 0 }
    opt.parse!(ARGV)
  }
  $source = ARGF.read unless $source
end