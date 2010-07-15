#!/usr/bin/ruby
require 'rubygems'
require 'quick_cgi'

QuickCGI::Page.run do
  title "Test page"
  @test_variable = 'three'
  @params_string = params.inspect
  render_haml('test.haml')
end
