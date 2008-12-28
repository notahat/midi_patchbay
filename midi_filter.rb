framework 'Cocoa'
$LOAD_PATH << NSBundle.mainBundle.resourcePath
require 'midi'

class Object
  # Returns the metaclass of this object. For an explanation of metaclasses, see:
  # http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html
  def metaclass
    class << self
      self
    end
  end
  
  # Evaluates the block in the context of this object's metaclass.
  def meta_eval(&block)
    metaclass.instance_eval(&block)
  end
  
  def define_instance_method(symbol, code:code)
    meta_eval do
      undef_method(symbol)
      define_method(symbol, eval("Proc.new {|message| #{code} }"))
    end
  end
end

class MIDIFilter
  def process(message)
    [message, message + 1.major_third, message + 1.perfect_fifth]
  end
  
  def test
    puts 42
  end
  
  def filter(raw_message)
    # Parse.
    messages = MIDI::Message.parse(raw_message)
    
    # Fiddle.
    messages = messages.map {|message| process(message) }
    messages.flatten!
    messages.compact!
    
    # Construct.
    data = NSMutableData.data
    messages.each {|message| data.appendData(message.to_data) }
    data
  end
end
