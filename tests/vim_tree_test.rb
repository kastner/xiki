require 'test/unit'
$:.unshift File.expand_path("..")
require 'lib/xiki/vim/tree'

class MockWindow
  def initialize(x,y)
    @x = x
    @y = y
  end

  def cursor
    [@y, @x].to_a
  end
end

class MockBuffer
  def initialize(lines)
    @lines = lines
  end

  def [](i)
    @lines[i-1]
  end
end

class VimTreeLineTest < Test::Unit::TestCase
  def setup
    @vtree = VimTree.new
  end

  def test_finding_a_weird_token
    assert_equal "+ performance_schema/", ts("+ performance_schema/ -- yah heardt", 3)
  end

  def test_finding_a_weird_token_starting_the_string
    assert_equal "+ performance_schema/", ts("+ performance_schema/ -- yah heardt")
  end

  def test_not_finding_a_token
    assert_equal [nil, nil], ts("                ", 16, -1)
  end

  def test_short_strings
    assert_equal "dbs", ts("dbs", 1)
  end

  def test_weird_start
    assert_equal 1, ts(" + test/", 1, 1)
  end

  def test_weird_start2
    assert_equal 2, ts("  < test/", 5, 1)
  end

  def test_1pwd_string
    assert_equal "1Password/", ts("1Password/")
  end

  def test_app
    assert_equal "app", ts("app", 1)
  end

  def test_app_with_whitespace
    assert_equal "<< app/", ts("    << app/", 8)
    assert_equal 4, ts("    << app/", 8, 1)
  end

  def test_app_1pwd
    @vtree.window = MockWindow.new(9, 2)
    @vtree.buffer = MockBuffer.new(["<< app/", "  + 1Password/"])
    assert_equal "app/1Password", @vtree.overall
  end

  def test_stop_moving_up_chain
    @vtree.window = MockWindow.new(9, 3)
    @vtree.buffer = MockBuffer.new(["<< apache/", "<< app/", "  + 1Password/"])
    assert_equal "app/1Password", @vtree.overall
  end

  def test_ignore_siblings
    @vtree.window = MockWindow.new(9, 3)
    @vtree.buffer = MockBuffer.new(["<< app/", "  + 1Password/", "  + FaceTime/"])
    assert_equal "app/FaceTime", @vtree.overall
  end

  def test_ignore_more_siblings
    @vtree.window = MockWindow.new(9, 5)
    @vtree.buffer = MockBuffer.new(["<< app/", "  + 1Password/", "  + /", "  + App Store/", "  + FaceTime/"])
    assert_equal "app/FaceTime", @vtree.overall
  end

  def test_ignore_even_more_siblings
    @vtree.window = MockWindow.new(15, 19)
    @vtree.buffer = MockBuffer.new(big_example)
    assert_equal "app/Calculator", @vtree.overall
  end

  def ts(str, pos=0, field=0)
    ret = @vtree.get_token_and_start(str, pos)
    return ret if field == -1
    return ret[field]
  end

  def big_example
    %Q{
  all
    << accounts/
    << address book/
    << agenda/
    << all/
    << amazon/
    << apache/
    << app/
      + 1Password/
      + /
      + /
      + /
      + Adobe Download Assistant/
      + /
      + /
      + App Store/
      + Automator/
      + Calculator/
      + Calendar/
      + Chess/
      + Cloud/
      + Contacts/
    }.split("\n")
  end
end
