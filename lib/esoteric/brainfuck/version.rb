# coding: utf-8

module Esoteric
  module Brainfuck
    module VERSION
      unless defined? MAJOR
        MAJOR = 0
        MINOR = 0
        TINY  = 2
        MINESCULE = nil

        STRING = [MAJOR, MINOR, TINY, MINESCULE].compact.join('.')

        SUMMARY = "Brainf*ck #{STRING}"
      end
    end
  end
end
