require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
require 'esoteric/whitespace'

$ruby_parser ||= RubyParser.new
#$DEBUG = true

describe Esoteric::Whitespace::Parser do
  before :all do
    @parser_class = Esoteric::Whitespace::Parser
    @source = File.read(File.join($SPEC_DIR.parent, 'examples', 'hi.ws'))
    @remove_runtime_expression = lambda { |ast|
      3.times { ast.shift }
      return ast.shift
    }
    @parsed_expressions = {
      "   \t\n"     => $ruby_parser.parse('$stack.push 1').to_a,
      " \n "        => $ruby_parser.parse('$stack.push $stack.last').to_a,
      " \t  \t\n"   => $ruby_parser.parse('$stack.push $stack[-2]').to_a,
      " \n\t"       => $ruby_parser.parse('$stack.push $stack.pop, $stack.pop').to_a,
      " \n\n"       => $ruby_parser.parse('$stack.pop').to_a,
      " \t\n \t\n"  => $ruby_parser.parse('top = $stack.pop; 1.times { $stack.pop }; $stack.push top').to_a,
      "\t   "       => $ruby_parser.parse('y, x = $stack.pop, $stack.pop; $stack.push x + y').to_a,
      "\t  \t"      => $ruby_parser.parse('y, x = $stack.pop, $stack.pop; $stack.push x - y').to_a, 
      "\t  \n"      => $ruby_parser.parse('y, x = $stack.pop, $stack.pop; $stack.push x * y').to_a,
      "\t \t "      => $ruby_parser.parse('y, x = $stack.pop, $stack.pop; $stack.push x / y').to_a,
      "\t \t\t"     => $ruby_parser.parse('y, x = $stack.pop, $stack.pop; $stack.push x % y').to_a,
      "\t\t "       => $ruby_parser.parse('val, addr = $stack.pop, $stack.pop; $heap[addr] = val').to_a,
      "\t\t\t"      => $ruby_parser.parse('addr = $stack.pop; $stack.push $heap[addr]').to_a,
      "\n   \t\n"   => $ruby_parser.parse('def st;end').to_a,
      "\n \t \t\n"  => $ruby_parser.parse('st()').to_a,
      "\n \n \t\n"  => $ruby_parser.parse('if true; st(); else; end').to_a,
      "\n\t  \t\n"  => $ruby_parser.parse('if $stack.pop == 0; st(); else; end').to_a,
      "\n\t\t \t\n" => $ruby_parser.parse('if $stack.pop < 0; st(); else; end').to_a,
      "\n\t\n"      => nil,
      "\n\n\n"      => $ruby_parser.parse('exit 0').to_a,
      "\t\n  "      => $ruby_parser.parse('$stdout.print $stack.pop.chr').to_a,
      "\t\n \t"     => $ruby_parser.parse('$stdout.print $stack.pop.to_i').to_a,
      "\t\n\t "     => $ruby_parser.parse('$stack.push $stdin.getc.ord').to_a,
      "\t\n\t\t"    => $ruby_parser.parse('$stack.push $stdin.getc.to_i').to_a,
    }
  end

  it_should_behave_like 'parser'

  it_should_parse "   \t\n"     # push 1
  it_should_parse " \n "        # dup
  it_should_parse " \t  \t\n"   # copy 1
  it_should_parse " \n\t"       # swap 1
  it_should_parse " \n\n"       # discard
  it_should_parse " \t\n \t\n"  # slide 1
  it_should_parse "\t   "       # add
  it_should_parse "\t  \t"      # sub
  it_should_parse "\t  \n"      # mul
  it_should_parse "\t \t "      # div
  it_should_parse "\t \t\t"     # mod
  it_should_parse "\t\t "       # heap write
  it_should_parse "\t\t\t"      # heap read
  it_should_parse "\n   \t\n"   # label st
  it_should_parse "\n \t \t\n"  # call st
  it_should_parse "\n \n \t\n"  # jump st
  it_should_parse "\n\t  \t\n"  # jump_zero st
  it_should_parse "\n\t\t \t\n" # jump_negative st
  it_should_parse "\n\t\n"      # return
  it_should_parse "\n\n\n"      # exit
  it_should_parse "\t\n  "      # charactor out
  it_should_parse "\t\n \t"     # numeric out
  it_should_parse "\t\n\t "     # charactor in
  it_should_parse "\t\n\t\t"    # numric in
end
