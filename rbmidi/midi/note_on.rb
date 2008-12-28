require 'midi/message'

class String
  def chop_up(size)
    result = []
    i = 0
    while i < length
      result << self[i, size]
      i += size
    end
    result
  end
end  

module MIDI
  class NoteOn < Message
    def self.parse(raw_message)
      channel = (raw_message.getByte(0) & 0xF) + 1
      messages = []
      i = 1
      while i < raw_message.length
	messages << NoteOn.new(channel, raw_message.getByte(i), raw_message.getByte(i+1))
	i += 2
      end
      messages
    end
    
    def initialize(channel, note, velocity)
      @channel  = channel
      @note     = Note.new(note)
      @velocity = velocity
    end
    
    attr_accessor :channel
    attr_accessor :note
    attr_accessor :velocity
    
    def +(value)
      case value
        when Interval
          NoteOn.new(@channel, @note + value, @velocity)
        else
          raise ArgumentError
      end
    end
    
    def to_s
      [0x90 + channel-1, note.to_i, velocity].map {|c| c.chr }.join
    end
    
    def to_data
      data = NSMutableData.dataWithLength(3)
      data.setByteAt(0, to:0x90 + channel-1)
      data.setByteAt(1, to:note.to_i)
      data.setByteAt(2, to:velocity)
      data
    end
    
    def inspect
      "<NoteOn channel=#{@channel}, note=#{@note.inspect}, velocity=#{@velocity}>"
    end
  end
end
