xiki_dir = File.expand_path "#{File.dirname(__FILE__)}/.."
Dir.chdir xiki_dir

# Used by a lot of classes
class Xiki
  @@dir = "#{Dir.pwd}/"   # Store current dir when xiki first launches

  # TODO Just use XIKI_DIR from above?

  def self.dir
    @@dir
  end
end

$el.el4r_lisp_eval '(ignore-errors (kill-buffer "Issues Loading Xiki"))' if $el
$el.set_process_query_on_exit_flag($el.get_buffer_process("*el4r:process*"), nil) if $el


# $LOAD_PATH << "#{xiki_dir}/lib"
# Require some of the core files
require 'rubygems'
require 'xiki/trouble_shooting'
require 'xiki/ol'
require 'xiki/requirer'
require 'xiki/text_util'
Requirer.require_classes ['xiki/notes']
require 'xiki/launcher'
require 'xiki/mode'
require 'xiki/menu'

# Launcher.add_class_launchers classes
class Xiki

  $el.elvar.xiki_loaded_once = nil if $el && ! $el.boundp(:xiki_loaded_once)

  def self.menu
    %`
    - .tests/
    - .github/
      - commits/
      - files/
    - .setup/
      - install command/
        | Double-click on these lines to add the executable 'xiki' command to
        | your path:
        |
        @#{Xiki.dir}/
          $ ruby etc/command/copy_xiki_command_to.rb /usr/local/bin/xiki
        |
        | Then you can type 'xiki' on a command line outside of emacs as a
        | shortcut to opening xiki and opening menus, like so:
        |
        |   $ xiki computer
        |
      - .install icon/
        | Double-click on this line to make .xiki files have the xiki 'shark'
        | icon:
        |
        - install/
        |
        | When you right-click on a .xiki file and select "Open With" and
        | choose emacs, the files will be assigned the xiki shark icon.
        |
      - install global shortcut/
        - 1) With cursor on the following, type open+in+os, then click "Install"
          @ #{Xiki.dir}etc/services/Xiki Menu.workflow

        - 2) In Mac OS, open
          | System Preferences > Keyboard > Keyboard Shortcuts > Services

        - 3) Scroll down to the bottom and give "Xiki Menu" the shortcut
          | Command+Control+X

        - 4) Try it out by typing Command+Control+X from any application
          | It should prompt you to type a xiki menu
      - .process/
        - status/
        - start/
        - stop/
        - restart/
        - log/
      - el4r/
        > Configure
        @#{Xiki.dir}
          % sudo bash etc/install/el4r_setup.sh

        - docs/
          | This will create/update files in your home directory, which make el4r
          | point to the version of ruby currently active.
          |
          | You can run this multiple times.
      - .misc/
        - .dont show welcome/
      @web interface/
    - api/
      > Summary
      Here are some functions that will always be available to menu classes,
      even external ones.
      |
      | Put pipes at beginning of lines (except bullets etc)
      |   p Xiki.quote "hey\\nyou"
      |
      | Return path to tree's root including current line, will be a list with 1
      | path unless nested.
      |   p Xiki.trunk
      |
      Here are some functions that will always be available toxxxxxxxxxxxxxxxxxx
    `

  end

  def self.install_icon arg

    emacs_dir = "/Applications/Aquamacs Emacs.app"

    return "- Couldn't find #{emacs_dir}!" if ! File.exists?("#{emacs_dir}")

    plist_path = "#{emacs_dir}/Contents/Info.plist"

    plist = File.read "#{emacs_dir}/Contents/Info.plist"

    # TODO
    # "Back up plist file - where - xiki root?!
    # "Tell them where it was backed up!
    # "Show diffs of change that was made!

    return "- This file wasn't in the format we expected: #{plist_path}" if plist !~ %r"^\t<key>CFBundleDocumentTypes</key>\n\t<array>\n"

    # TODO
    # .plist
      # if change was already made, say so

    # TODO

    # 1. Copy icon into app
    # cp "#{Xiki.dir}etc/shark.icns" "/Applications/Aquamacs Emacs.app/Contents/Resources/"
    # - /Applications/Aquamacs Emacs.app/
    #   - Contents/Resources/
    #     + shark.icns
    #     + emacs-document.icns

    # 2. Update Info.plist
    # /Applications/Aquamacs Emacs.app/Contents/
    #   - Info.plist
    #     |+ 		<dict>
    #     |+ 			<key>CFBundleTypeExtensions</key>
    #     |+ 			<array>
    #     |+ 				<string>notes</string>
    #     |+ 				<string>menu</string>
    #     |+ 				<string>xiki</string>
    #     |+ 			</array>
    #     |+ 			<key>CFBundleTypeIconFile</key>
    #     |+ 			<string>shark.icns</string>
    #     |+ 			<key>CFBundleTypeName</key>
    #     |+ 			<string>Xiki File</string>
    #     |+ 			<key>CFBundleTypeOSTypes</key>
    #     |+ 			<array>
    #     |+ 				<string>TEXT</string>
    #     |+ 				<string>utxt</string>
    #     |+ 			</array>
    #     |+ 			<key>CFBundleTypeRole</key>
    #     |+ 			<string>Editor</string>
    #     |+ 		</dict>

    # 3. Tell user to drag the .app icon out of the "Applications" folder and back in
    #   - Or google to find a command that will do the same thing


    "- TODO: finish implementing!"
  end

  def self.insert_menu
    line = Line.value
    indent = Line.indent line
    blank = Line.blank?

    prefix = Keys.prefix

    # If line not blank, usually indent after

    Line.<<("\n#{indent}  @") if ! blank

    # If at end of line, and line not blank, go to next line

    # Todo: if dash+, do auto-complete even if exact match - how to implement?

    input = Keys.input(:timed=>true, :prompt=>"Start typing a menu that might exist (or type 'all'): ")

    View << input

    Launcher.launch
  end

  def self.open_menu

    return Launcher.open("- last/") if Keys.prefix_u

    input = Keys.input(:timed=>true, :prompt=>"Start typing a menu that might exist (or type 'all'): ")
    View.to_buffer "menu"
    Notes.mode
    View.kill_all
    View << "#{input}\n"
    View.to_highest
    Launcher.launch
  end

  def self.menus
    CodeTree.menu
  end

  def self.github page
    Firefox.url case page
      when 'files'; "http://github.com/trogdoro/xiki"
      when 'commits'; "https://github.com/trogdoro/xiki/commits/master"
      end
    ".flash - Opened in browser!"
  end

  def self.dont_search
    $xiki_no_search = true
    nil
  end

  def self.quote_spec txt
    txt.
      gsub(/^/, '| ').
      gsub(/ +$/, '').
      gsub(/^\|(        )([+-])/) {|o| "|#{$2 == '-' ? '+' : '-'}#{$1}"}   # Make "expected" be green

  end

  def self.tests clazz=nil, describe=nil, test=nil, quote=nil

    prefix = Keys.prefix :clear=>1

    return if self.nav_to_line   # If on line to navigate to, just navigate

    # If no class, list all classes

    if clazz.nil?
      return ["all/"] + Dir["#{Xiki.dir}/spec/*_spec.rb"].entries.map{|o| "#{o[/.+\/(.+)_spec\.rb/, 1]}/"}
    end

    # If /class, list describes

    path = Bookmarks["$x/spec/#{clazz}_spec.rb"]

    sync_options = prefix == :u ? {} : {:sync=>1}

    if describe.nil?
      return View.open path if prefix == "open"

      if clazz == "all"   # Run all specs
        return self.quote_spec( #prefix == :u ?
          Console.run("rspec spec", sync_options.merge(:dir=>Xiki.dir))
          )
      end

      txt = File.read path
      return "- all/\n" + txt.scan(/^ *describe .*"(.+)"/).map{|o|
        "- #{o}/"
      }.join("\n")
    end

    # If /class/describe, list tests

    if test.nil?

      return self.nav_to path, describe if prefix == "open"

      if describe == "all"   # Run whole test
        return self.quote_spec(
          Console.run("rspec spec/#{clazz}_spec.rb", sync_options.merge(:dir=>Xiki.dir))
          )
      end

      txt = File.read path

      is_match = false
      return "- all/\n" + txt.scan(/^ *(describe|it) .*"(.+)"/).map{|o|
        next is_match = o[1] == describe if o[0] == "describe"   # If describe, set whether it's a match
        next if ! is_match
        "- #{o[1]}/"
      }.select{|o| o.is_a? String}.join("\n")

    end

    # If /class/describe/test, run test

    if ! quote
      if test == "all"   # Run all for describe
        return self.quote_spec(
          Console.run("rspec spec/#{clazz}_spec.rb -e \"#{describe}\"", sync_options.merge(:dir=>Xiki.dir))
          #           Console.run("rspec spec", sync_options.merge(:dir=>Xiki.dir))
          )
      end

      # If U prefix, just jump to file
      if prefix == "open"
        return self.nav_to path, describe, test if prefix == "open"
      end


      # Run it
      command = "rspec spec/#{clazz}_spec.rb -e \"#{describe} #{test}\""
      result = Console.run command, :dir=>"$x", :sync=>true

      if result =~ /^All examples were filtered out$/
        TextUtil.title_case! clazz
        describe.sub! /^#/, ''

        return %`
          > Test doesn't appear to exist.  Create it?
          | Copy this text into the file:

          @#{path}
            | describe #{clazz}, "##{describe}" do
            |   it "#{test}" do
            |     #{clazz}.#{describe}.should == "hi"
            |   end
            | end
        `
      end

      return self.quote_spec result
    end

    # Quoted line, so jump to line number

    nil
  end

  def self.nav_to_line
    match = Line.value.match(/([\/\w.]+)?:(\d+)/)
    return if ! match

    file, line = match[1..2]
    file.sub! /^\.\//, Bookmarks["$x"]
    View.open file
    View.to_line line.to_i

    return true   # Did navigate
  end

  def self.nav_to path, *searches
    View.open path
    View.to_highest
    searches.each { |s| Search.forward "[\"']#{$el.regexp_quote s}[\"']" }
    Move.to_axis
    Color.colorize :l
    nil
  end

  def self.trunk options={}
    self.path options
  end

  def self.path options={}
    Tree.path options
  end

  def self.quote txt
    Tree.quote txt
  end

  # Other .init mode defined below
  def self.on_open
    orig = View.name
    name = orig[/(.+?)\./, 1]

    file = View.file

    # Figure out whether menu or class
    txt = File.read file
    kind = txt =~ /^class / ? "class" : "menu"
    require_menu file, :force_as=>kind

    View.kill

    Buffers.delete name if View.buffer_open? name

    View.to_buffer name
    Notes.mode

    View.dir = "/tmp/"

    View.<< "- #{name}/\n", :dont_move=>1
    Launcher.launch

  end

  def self.init

    # Get rest of files to require

    classes = Dir["./lib/xiki/*.rb"]

    classes = classes.select{|i|
      i !~ /\/ol.rb$/ &&   # Don't load Ol twice
      i !~ /\/xiki.rb$/ &&   # Remove self
      i !~ /\/key_bindings.rb$/ &&   # Remove key_bindings
      i !~ /__/   # Remove __....rb files
    }

    #     classes = Dir["**/*.rb"]
    #     classes = classes.select{|i|
    #       i !~ /xiki.rb$/ &&   # Remove self
    #       i !~ /key_bindings.rb$/ &&   # Remove key_bindings
    #       i !~ /\// &&   # Remove all files in dirs
    #       i !~ /tests\// &&   # Remove tests
    #       i !~ /__/   # Remove __....rb files
    #     }

    classes.map!{|i| i.sub(/\.rb$/, '')}.sort!

    # Require classes
    Requirer.require_classes classes

    # key_bindings has many dependencies, require it last
    Requirer.require_classes ['./lib/xiki/key_bindings.rb']

    Launcher.add_class_launchers classes.map{|o| o[/.*\/(.+)/, 1]}
    Launcher.reload_menu_dirs

    Launcher.add "xiki"

    # Pull out into .define_mode

    Mode.define(:xiki, ".xiki") do
      Xiki.on_open
    end

    if $el
      # If the first time we've loaded
      if ! $el.elvar.xiki_loaded_once && ! Menu.line_exists?("misc config", /^- don't show welcome$/) && ! View.buffer_visible?("Issues Loading Xiki")
        Launcher.open("welcome/", :no_search=>1)
      end

      $el.elvar.xiki_loaded_once = true
    end

  end

  def self.process action

    case action
    when "status"
      "- #{`xiki status`}"
    when "stop"
      response = `xiki stop`
      response = "apparently it wasn't running" if response.blank?
      response.gsub /^/, '- '
    when "restart"
      response = `xiki restart`
      response = "apparently it wasn't running" if response.blank?
      response.gsub /^/, '- '
    when "log"
      "@/tmp/xiki_process.rb.output"
    when "start"
      result = `xiki`
      "- started!"
    end
  end

  def self.dont_show_welcome
    Menu.append_line "misc config", "- don't show welcome"
  end

  def self.finished_loading?
    @@finished_loading
  end
end
