# coding: utf-8

module Esoteric
  class PreProcessor
    def self.process(source)
      new.process(source)
    end

    def process(source)
      r_declares, libs   = requires 
      m_declares, source = expand_macro(source)
      result = {
        :libs     => libs
        :declares => r_declares + m_declares,
        :source   => source
      }
    end

    def requires
      [[], []]
    end

    def expand_macro(source)
      [[], source]
    end
  end
end
