require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
require 'esoteric/brainfuck'

$ruby_parser ||= RubyParser.new

describe Esoteric::Brainfuck::Parser do
  before :all do
    @parser_class = Esoteric::Brainfuck::Parser
    @source = File.read(File.join($SPEC_DIR.parent, 'examples', 'hi.bf'))
  end

  before :all do
    @remove_runtime_expression = lambda { |ast|
      5.times { ast.shift }
      return ast.shift
    }
    @parsed_expressions = {
      '+'   => $ruby_parser.parse('set_value(get_value + 1)').to_a,
      '-'   => $ruby_parser.parse('set_value(get_value + -1)').to_a,
      '>'   => $ruby_parser.parse('$pc += 1').to_a,
      '<'   => $ruby_parser.parse('$pc += -1').to_a,
      '.'   => $ruby_parser.parse('print get_value.chr').to_a,
      ','   => $ruby_parser.parse('set_value(getc.ord)').to_a,
      '[]'  => $ruby_parser.parse('until get_value == 0; end').to_a,
    }
  end

  it_should_behave_like 'parser'

  it_should_parse '+'
  it_should_parse '-'
  it_should_parse '>'
  it_should_parse '<'
  it_should_parse '.'
  it_should_parse ','
  it_should_parse '[]'
end
