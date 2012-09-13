class Gems
  def self.menu
    "
    - .list/
      - */
        - */
          - .readme/
          - .source/
          - .uninstall/
    - .environment/
    "
  end

  def self.list name=nil

    # If nothing passed, list noames

    if name.nil?
      gem_list = Console.sync("gem list")
      return gem_list.gsub(/ \(.+/, "").gsub(/.+/, "- \\0/")
    end

    # If just name, list versions

    txt = Console.sync("gem list #{name}")
    versions = txt[/\((.+)\)/, 1]
    versions = versions.split ", "

    return versions.map{|o| "#{o}/"}


    #     # If version passed, show options
    #     "
    #     - nothing at this point/
    #     "

  end

  def self.uninstall name, version
    txt = "sudo gem uninstall #{name} -v #{version}"
    Console.run txt

    ".flash - Running gem uninstall command in shell..."
  end

  def self.gem_dir name
    Gem::Specification.find_by_name(name).gem_dir+"/"
  end

  def self.source name, version
    dir = Gems.gem_dir name

    "@#{dir}"
  end

  def self.readme name, version

    dir = Gems.gem_dir name

    entries = Dir.new(dir).entries
    file = entries.find{|o| o =~ /^readme/i}

    return "| No readme file found in\n@#{dir}" if ! file

    path = "#{dir}#{file}"

    Tree << "@#{path}"

    Launcher.enter_all
    nil
  end

  def self.environment
    Console.sync("gem environment").strip.gsub(/^/, '| ')
  end

end
