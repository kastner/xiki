class Block

  #   def self.value
  #     res = []
  #     with(:save_excursion) do
  #       found = re_search_backward "^ *$", nil, 1
  #       if found
  #         end_of_line
  #         forward_char
  #       end
  #       res << point
  #       re_search_forward "^ *$", nil, 1
  #       beginning_of_line
  #       res << point
  #     end
  #     res
  #   end

  def self.do_as_wrap

    if Keys.prefix_u?
      # Grab paragraph and remove linebreaks

      orig = Location.new
      txt = View.paragraph :delete => true, :start_here => true
      txt.gsub! "\n", " "
      txt.sub!(/ $/, "\n")
      View.insert txt
      orig.go

      Line.to_left
      View.insert "> "
      $el.fill_paragraph nil
      txt = View.paragraph(:delete => true)
      View.insert txt.gsub(/^  /, '> ')
      return
    end

    $el.fill_paragraph nil
  end

  def self.do_as_something

    prefix = Keys.prefix
    txt, left, right = View.txt_per_prefix prefix

    result = yield txt

    # Insert result at end of block
    orig = Location.new
    View.cursor = right
    Line.to_left

    if prefix.nil?
      View.insert(">>\n"+result.strip+"\n") unless result.blank?
    else
      View.insert(result.strip.gsub(/^/, '  ')+"\n") unless result.blank?
    end

    orig.go
  end

  def self.>> txt
    orig = Location.new
    ignore, left, right = View.block_positions "^>"
    View.cursor = right

    View.insert(">>\n#{txt.strip}\n") unless txt.blank?
    orig.go
  end

end
