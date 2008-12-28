

module MIDI
  class Message
    def self.parse(raw_message)
      case raw_message.getByte(0)
        when 0x90..0x9F  # Note on
          NoteOn.parse(raw_message)
        else
          nil
      end
    end
    
    def append_to(data)
      
    end
  end
end
