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
  def get_token_and_start(line, start=nil)
    start = start || get_cursor[0] # x position of the cursor
    line = obj.line if line.respond_to?(:line)

    left_str = line[start, 1]

    old_start = start
    while (start > 0) do
      start -= 1
      left_str = line[start..old_start]
      break if left_str[0].chr.match(/\W/)
    end

    start = start+1 unless line[start].chr == " " || start == 0
    start = start-1 if is_special?(line[start-1].chr)
    start = start+1 if line[start].chr == " "

    str = line[start..-1][/((. )?.+?)(\s|$)/, 1]
    str = nil if str == " "
    start = nil if str.nil?
    return [str, start]
  end

  def get_cursor(obj=VIM::Window.current)
    obj.cursor.reverse
  end

  def get_line(i, obj=VIM::Buffer.current)
    begin
      return obj[i]
    rescue IndexError
      puts Kernel.caller.inspect
    end
  end

  def overall
    start = get_cursor[0]
    token, start = get_token_and_start(get_line(get_cursor[1]), start)
    unless is_special?(token[0].chr)
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

    return clean_up(tokens)
  end

  def clean_up(tokens)
    return tokens.reverse.map{|t| t[/^(. )?(.*)$/,2]}.join("/")
  end

  def is_special?(char)
    ["+", "-"].include?(char)
  end
end
