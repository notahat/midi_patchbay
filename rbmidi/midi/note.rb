module MIDI
  OCTAVE_NAMES = %w{C C# D D# E F F# G G# A# B}
  NAMES = (0..127).map do |i|
    octave = i / 12
    note   = i % 12
    "#{OCTAVE_NAMES[note]}#{octave-1}"
  end
  
  class Note
    def initialize(value)
      @value = value.to_i
    end
    
    def to_i
      @value
    end
    
    def ==(value)
      @value == value.to_i
    end
    
    def +(interval)
      Note.new(@value + interval.to_i)
    end
    
    def inspect
      "#{NAMES[@value]}(#{@value})"
    end
  end
end
