# coding: utf-8

module Esoteric
  module Tetete
    module VERSION
      unless defined? MAJOR
        MAJOR = 0
        MINOR = 0
        TINY  = 2
        MINESCULE = nil

        STRING = [MAJOR, MINOR, TINY, MINESCULE].compact.join('.')

        SUMMARY = "てってってー #{STRING}"
      end
    end
  end
end
