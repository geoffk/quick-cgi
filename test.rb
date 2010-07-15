#!/usr/bin/ruby
require 'rubygems'
require 'quick_cgi'

QuickCGI::Page.run do
  title "Test page"
  @test_variable = 'three'
  @params_string = params.inspect
  render(:haml=>'test.haml')
  render(:text=>'Hello, this is some text')
end
