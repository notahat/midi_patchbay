require 'spec'
require 'midi'

describe MIDI::NoteOn do
  it "should parse a single message" do
    messages = MIDI::NoteOn.parse("\x97\x3c\x7f")
    messages.length.should == 1
    messages.first.instance_eval do
      channel.should    == 8
      note.should       == 0x3c
      velocity.should   == 0x7f
    end
  end
  
  it "should parse multiple messages" do
    messages = MIDI::NoteOn.parse("\x97\x3c\x7f\x3d\x40\x3e\x20")
    messages.length.should == 3
    messages[0].instance_eval do
      channel.should  == 8
      note.should     == 0x3c
      velocity.should == 0x7f
    end
    messages[1].instance_eval do
      channel.should  == 8
      note.should     == 0x3d
      velocity.should == 0x40
    end
    messages[2].instance_eval do
      channel.should  == 8
      note.should     == 0x3e
      velocity.should == 0x20
    end
  end
  
  it "should allow adding an interval" do
    message = MIDI::NoteOn.new(8, 60, 127)
    new_message = message + 1.octave
    new_message.instance_eval do
      channel.should  == 8
      note.should     == 72
      velocity.should == 127
    end
  end
  
  it "should convert to a string" do
    message = MIDI::NoteOn.new(0x8, 0x3c, 0x7f)
    message.to_s.should == "\x97\x3c\x7f"
  end
end
