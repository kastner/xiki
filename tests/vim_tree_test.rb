require 'test/unit'
$:.unshift File.expand_path("..")
require 'lib/xiki/vim/tree'

class VimTreeLineTest < Test::Unit::TestCase
  def setup
    @pos = [136,6].reverse
    @tree = Tree.new
    @vtree = VimTree.new
  end

  def test_finding_a_token
    assert_equal "returns", @vtree.get_token_and_start("current\t\treturns the current", 16)[0]
  end

  def test_finding_a_weird_token
    assert_equal "+ performance_schema/", @vtree.get_token_and_start("+ performance_schema/ -- yah heardt", 3)[0]
  end

  def test_finding_a_weird_token_starting_the_string
    assert_equal "+ performance_schema/", @vtree.get_token_and_start("+ performance_schema/ -- yah heardt", 0)[0]
  end

  def test_finding_the_start_pos_of_a_token
    assert_equal 9, @vtree.get_token_and_start("current\t\treturns the current", 16)[1]
  end

  def test_not_finding_a_token
    assert_equal [nil, nil], @vtree.get_token_and_start("                ", 16)
  end

  def test_short_strings
    assert_equal "dbs", @vtree.get_token_and_start("dbs", 1)[0]
  end

  def test_weird_start
    assert_equal 1, @vtree.get_token_and_start(" + test/", 1)[1]
  end
end
