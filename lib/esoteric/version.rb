# coding: utf-8

module Esoteric
  module VERSION
    unless defined? MAJOR
      MAJOR = 0
      MINOR = 0
      TINY  = 1
      MINESCULE = nil

      STRING = [MAJOR, MINOR, TINY, MINESCULE].compact.join('.')

      SUMMARY = "esoteric #{STRING}"
    end
  end
end
