module MIDI
  class Interval
    NAMES = %w{P1 m2 M2 m3 M3 P4 TT P5 m6 M6 m7 M7 P8}
    
    def initialize(value)
      @value = value.to_i 
    end
    
    def to_i
      @value
    end
    
    def ==(value)
      @value = value.to_i
    end
    
    def inspect
      NAMES[@value]
    end
    
    module FixnumExtensions
      # INTERVAL_NAMES = %w{
      #   unity minor_second major_second minor_third major_third perfect_fourth tritone
      #  perfect_fifth minor_sixth major_sixth minor_seventh major_seventh octave
      # }
      
      # def self.included(base)
      #  INTERVAL_NAMES.each_with_index do |name, index|
      #    base.define_method(name) { MIDI::Interval.new(index * self) }
      # end
      # end
      
      def octaves
	MIDI::Interval.new(12 * self)
      end
      alias_method :octave, :octaves
      
      def semitones
        MIDI::Interval.new(self)
      end
      alias_method :semitone, :semitones
    end
    
  end
end

class Fixnum
  include MIDI::Interval::FixnumExtensions
end
