require 'spec'
require 'midi'

describe MIDI::Note do
  before do
    @note = MIDI::Note.new(60)
  end
  
  it "should return the MIDI note value for to_i" do
    @note.to_i.should == 60
  end
  
  it "should be equal to its integer value" do
    @note.should == 60
  end
  
  it "should be equal to the same note" do
    @note.should == MIDI::Note.new(60)
  end
  
  it "should allow adding an interval" do
    new_note = @note + 1.octave
    new_note.class.should == MIDI::Note
    new_note.to_i.should  == 72
  end
  
  it "should return the name of the note when inspected" do
    @note.inspect.should == "C4(60)"
  end
  
end
