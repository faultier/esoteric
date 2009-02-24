require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
require 'esoteric/tetete'

describe Esoteric::Tetete::Parser do
  before :all do
    @parser_class = Esoteric::Tetete::Parser
    @source = File.read(File.join($SPEC_DIR.parent, 'examples', 'tetete.ttt'))
  end

  it_should_behave_like 'parser'
end
