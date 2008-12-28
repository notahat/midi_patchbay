class NSData
  def operator[](index)
    getByte(index)
  end
end

class NSMutableData
  def operator[]=(index, value)
    setByte(index, value)
  end
end
