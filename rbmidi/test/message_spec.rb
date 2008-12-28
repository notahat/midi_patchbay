require 'spec'
require 'midi'

describe MIDI::Message do
  it "should parse a note-on message" do
    messages = MIDI::Message.parse("\x97\x3c\x7f")
    messages.length.should == 1
    messages.first.instance_eval do
      self.class.should == MIDI::NoteOn
      channel.should    == 8
      note.should       == 0x3c
      velocity.should   == 0x7f
    end
  end
end
