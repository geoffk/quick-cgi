#!/usr/bin/ruby
require 'rubygems'
require 'quick_cgi'

QuickCGI::Page.run do
  title "Test page"
  @test = "test variable"
  render_haml('test.haml')
end
