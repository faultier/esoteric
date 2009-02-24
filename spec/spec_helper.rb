# coding: utf-8

require 'pathname'
require 'pp'
require 'ruby2ruby'
require 'ruby_parser'

$TESTING  = true
$SPEC_DIR = Pathname(__FILE__).dirname.expand_path
$:.push File.join($SPEC_DIR.parent, 'lib')
require 'esoteric'

# for parsers

def it_should_parse(code)
  it "should parse #{code.inspect}" do
    exp = @parsed_expressions[code]
    parsed = @remove_runtime_expression.call(@parser_class.parse(code))
    if $DEBUG
      p exp
      p parsed
    end
    parsed.should be_eql(exp)
  end
end

describe 'parser', :shared => true do
  before :all do
    @remove_runtime_expression ||= lambda { |ast| return ast }
  end

  it 'require source code when generate' do
    lambda { @parser_class.new }.should raise_error(ArgumentError)
    lambda { @parser_class.new('') }.should_not raise_error(ArgumentError)
  end

  it 'should use logger when generate with logger' do
    logger = mock('DummyLogger')
    parser = @parser_class.new(@source, logger)
    parser.instance_eval{ @logger }.should be_equal(logger)
  end

  it 'require source code when parse' do
    lambda { @parser_class.parse }.should raise_error(ArgumentError)
  end

  it "should parse source to Ruby's AST as a array" do
    ast = @parser_class.parse(@source)
    ast.should be_kind_of(Array)
    # 当面の間、Parserの出力するASTが、
    # Ruby2Rubyが処理できる形のASTと互換性を保つ方針で
    lambda { Ruby2Ruby.new.process Sexp.from_array(ast) }.should_not raise_error
  end
end
