class Tree
  def self.<< txt
    line_number, line = Line.number, Line.value
    indent = line[/^ +/]
    txt.split("\n").each_with_index do |line, i|
      $curbuf.append(line_number + i, "#{indent}  #{line}")
    end
  end
end

class VimTree
  # recursive fucnction that stops when there are no more lines above with +
  def get_parent

  end

  # hard coding for now - tw spaces are valid
  def valid_char?(char, prev, prev2)
    return false if char.nil?

    # take care of nasty edge case first
    return true if char == "+" && prev == " " && prev2.match(/\w/)

    return false if char == " "
    return false if [char, prev, prev2].all? { |a| [' ', "\n", "\t"].any? {|ch| a == ch} }
    return true
  end

  def get_token(line, start=nil)
    start = start || get_cursor[0] # x position of the cursor
    line = obj.line if line.respond_to?(:line)

    left_str = line[start, 1]

    old_start = start
    while (start > 0) do
      start -= 1
      left_str = line[start..old_start]
      break if left_str[0].match(/\W/)
    end

    start = start+1 unless line[start] == " "
    start = start-1 if line[start-1] == "+"

    str = line[start..-1][/((\+ )?.+?)\s|$/, 1]
    return str
  end

  def g3et_token(line, start=nil)
    start = start || get_cursor[0] # x position of the cursor
    line = obj.line if line.respond_to?(:line)
    pos = start
    oldpos1 = pos
    oldpos2 = pos

    while valid_char?(line[pos], oldpos1, oldpos2)
      puts "pos is now #{pos} - #{line[pos]}"
      oldpos2 = oldpos1
      oldpos1 = line[pos]
      pos -= 1
    end

    start_pos = pos - 1
    pos = start[0]

    while valid_char?(line[pos], oldpos1, oldpos2)
      puts "pos is now #{pos} DUEX"
      oldpos2 = oldpos1
      oldpos1 = line[pos]
      pos += 1
    end

    end_pos = pos
    puts "end #{end_pos}, start #{start_pos}, str #{line}"
    return line[start_pos..end_pos]
  end

  def get_cursor(obj=VIM::Window.current)
    obj.cursor.chomp.split("\n").reverse
  end

  def overall
    # get the current token
    # move left to the begining
    # is it a top-level (no +)
    #   execute teh command
    # move up, check for plus
    #   is it a plus?
    #     move up
    #   is it whitespace?
    #     move up
    #   is it non-whitespace?
    #     figure out the token, repeat procedure
  end
end
