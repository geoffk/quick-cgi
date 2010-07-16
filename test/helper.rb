module QuickCGITestHelper
  def haml_string(str)
    lines = str.split("\n")
    remove = /^\s*/.match(lines[0])[0]
    if remove.nil? || remove.length == 0
      str
    else
      lines.map{|l| l.sub(remove,'')}.join("\n")
    end
  end
end

# Test
#include QuickCGITestHelper
#puts haml_string <<-HAML
#    first line
#    second line
#      third line indented
#      fourth line indented
#    fifth line
#      sixth line indented
#        seventh line indented twice
#  HAML
