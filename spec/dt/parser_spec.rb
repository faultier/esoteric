require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
require 'esoteric/dt'

describe Esoteric::DT::Parser do
  before :all do
    @parser_class = Esoteric::DT::Parser
    @source = File.read(File.join($SPEC_DIR.parent, 'examples', 'hi.dt'))
  end

  it_should_behave_like 'parser'
end
