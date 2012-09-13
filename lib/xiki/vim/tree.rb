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
  attr_writer :window, :buffer
  SPECIALS = %w[* << + -]

  def get_token_and_start(line, start=nil)
    start = start || get_cursor[0] # x position of the cursor
    line = obj.line if line.respond_to?(:line)

    left_str = line[start, 1]

    old_start = start
    while (start > 0) do
      start -= 1
      left_str = line[start..old_start]
      return [nil, nil] if left_str.nil?
      break if is_special?(left_str)
      break if left_str[0].chr.match(/\W/)
    end


    #line = adjust_for_special(line, start)
    start = start+1 unless line[start].chr == " " || start == 0
    start = start - special_length(line[start-1, 3]) if is_special?(line[start-1, 2])
    #start = start-1 if is_special?(line[start-1, 2])
    start = start+1 if line[start].chr == " "

    if line.index('/')
      str = line[/^.*\//]
    else
      str = line[/^.*(\/|$)/]
    end

    str.lstrip!
    str = nil if str.empty?
    start = nil if str.nil?
    return [str, start]
  end

  def adjust_for_special(cline, start)
    #start -= 1 unless start == 0
    line = cline[start, -1]

    #strip_special(line)
  end

  def special_length(line)
    return 0 unless is_special?(line)
    SPECIALS.each do |special|
      return special.length+1 if (line.index(special) == 0)
    end
  end

  def strip_special(line)
    line[special_length(line)..-2]
  end

  def get_cursor
    window.cursor.reverse
  end

  def get_line(i)
    begin
      return buffer[i]
    rescue IndexError
      puts Kernel.caller.inspect
    end
  end

  def buffer
    @buffer || VIM::Buffer.current
  end

  def window
    @window || VIM::Window.current
  end

  def overall
    start = get_cursor[0]
    token, start = get_token_and_start(get_line(get_cursor[1]), start)
    unless is_special?(token)
      return token
    end

    tokens = [token]

    line_number = get_cursor[1]
    
    while (line_number > 1 && line = get_line(line_number))  
      line_number -= 1

      token, start = get_token_and_start(line, start)
      break unless token

      # check to see if this is higher level or same
      token2, new_start = get_token_and_start(get_line(line_number), start - 2)
      break unless token2

      if new_start - start == -2
        tokens << token2
      end
    end

    #puts "path to pass to xiki: #{clean_up(tokens)}"
    return clean_up(tokens)
  end

  def clean_up(tokens)
    return tokens.reverse.map{|s| strip_special(s)}.join("/")
  end

  def is_special?(token)
    token && token.start_with?(*SPECIALS)
  end
end
