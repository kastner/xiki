function! XikiLaunch()
  ruby << EOF
    xiki_dir = ENV['XIKI_DIR']
    ['ol', 'vim/line', 'vim/tree'].each {|o| require "#{xiki_dir}/lib/xiki/#{o}"}
    line = Line.value
    indent = line[/^ +/]
    command = "xiki #{line}"
    result = `#{command}`

    # def whitecount(str)
    #   str[/^\s+/].length
    # end

    # def line_from_number(number)
    #   $curbuf[line_number]
    # end

    # def up_line(line_number)
    #   w = whitecount(line_from_number(line_number))
    #   return line_from_number(line_number) if line_number == 1
    #   v = whitecount(line_from_number(line_number - 1))

    #   if w == v # ignore it, same level, keep going up
    #     return up_line(line_number - 1)
    #   elsif w - v == 4 # it's a parent
    #     return line_from_number(line_number - 1)
    #   else
    #     # do nothing, we're all done here
    #     return nil
    #   end
    # end

    # def master_plan
    #   cmd = []
    #   command = "xiki #{cmd.map{|c| c.sub(^\s\+\sjoin("/")}"
    # end

    

    # if indent > 4
    #   # raise "Here I guess"
    # else

    #   subs = `#{command}`.chomp.split("\n")

    #   @storage[line + ":#{$curbuf.line_number}"] = subs

    #   subs.each do { |s| s.gsub(/\+\s+/,''); @sub_map[s] ||= []; @sub_map[s] << line}

    #   # raise "command this time: #{command} - #{line} - #{indent.length} #{$curbuf.line_number} space: #{ indent }"
    # end
    result = `xiki #{Line.value}`
    Tree << result
EOF
endfunction

nmap <silent> <2-LeftMouse> :call XikiLaunch()<CR>
imap <silent> <2-LeftMouse> <C-c>:call XikiLaunch()<CR>i
imap <silent> <C-CR> <C-c>:call XikiLaunch()<CR>i
nmap <silent> <C-CR> :call XikiLaunch()<CR>
