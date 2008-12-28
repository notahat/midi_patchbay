require 'test/unit'
require 'thoughtbot-shoulda'
require 'midi'

class IntervalTest < Test::Unit::TestCase
  setup do
    @interval = MIDI::Interval.new(7)
  end
  
  should "return the name of the interval when inspected" do
    assert_equal "P5", @interval.inspect
  end
  
end
