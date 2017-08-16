QuickCGI
Library to assist in the rendering of CGI pages using HAML.

Usage:

require 'quick_cgi' 

content = QuickCGI::Generator.generate(:admin_email => 'geoffk@garden-grove.org') do
  title "My title"
  @my_variable = "Hello"
  render(:haml=>'file.haml')
  render(:text=>'<p>My html text</p>')
end

print content

