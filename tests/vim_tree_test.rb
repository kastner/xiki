require 'test/unit'
$:.unshift File.expand_path("..")
require 'lib/xiki/vim/tree'

class VimTreeLineTest < Test::Unit::TestCase
  def setup
    @pos = [136,6].reverse
    @tree = Tree.new
    @vtree = VimTree.new
  end

  # def test_getting_a_position
    
  # end

  #def test_valid_chars
  #  assert @vtree.valid_char?("a", " ", " ")
  #  assert @vtree.valid_char?(" ", " ", "+")
  #end
#
#  def test_single_blank_allowed_if_bookened_properly
#    assert @vtree.valid_char?("a", "b", "c")
#    assert @vtree.valid_char?(" ", "a", "b")
#    assert @vtree.valid_char?("+", " ", "a")
#  end
#
#  def test_single_blank_not_allowed_if_bookened_improperly
#    assert ! @vtree.valid_char?("+", "b", "c")
#    assert ! @vtree.valid_char?(" ", "+", "b")
#    assert ! @vtree.valid_char?("+", " ", "+")
#  end
#
#  def test_invalid_chars
#    assert ! @vtree.valid_char?(" ", " ", "a")
#    assert ! @vtree.valid_char?(" ", "a", " ")
#  end

  def test_finding_a_token
    assert_equal "returns", @vtree.get_token("current\t\treturns the current", 16)
  end

  def test_finding_a_weird_token
    assert_equal "+ performance_schema/", @vtree.get_token("+ performance_schema/ -- yah heardt", 2)
  end
end
