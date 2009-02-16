# coding: utf-8
require 'pathname'
$TESTING  = true
$SPEC_DIR = Pathname(__FILE__).dirname.expand_path
$:.push File.join($SPEC_DIR.parent, 'lib')

require 'esoteric'
