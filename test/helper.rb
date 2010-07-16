module QuickCGITestHelper
  def remove_front_whitespace(str)
    lines = str.split("\n")
    remove = /^\s*/.match(lines[0])[0]
    if remove.nil? || remove.length == 0
      str
    else
      lines.map{|l| l.sub(remove,'')}.join("\n")
    end
  end

  def create_haml_file(str)
    @haml_file = Tempfile.new('quick_cgi_test')
    @haml_file.open
    @haml_file.write(remove_front_whitespace(str))
    @haml_file.close
    @haml_file.path
  end

end

