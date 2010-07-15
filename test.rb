#!/usr/bin/ruby
require 'rubygems'
require 'quick_cgi'

QuickCGI::Page.run do
  title "Test page"
  admin_email 'geoffk@ci.garden-grove.ca.us'
  @test_variable = 'three'
  @params_string = params.inspect
  render(:haml=>'test.haml')
  render(:text=>'Hello, this is some text')
end
