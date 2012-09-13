class Line
  def self.number(number=nil)
    number = number || $curbuf.line_number
  end
  def self.value
    $curbuf.[number]
  end
end
