#!/usr/bin/ruby
require 'rubygems'
require './lib/quick_cgi'

$DEBUG = false

content = QuickCGI::Generator.generate do
  title "Test page"
  admin_email 'geoffk@ci.garden-grove.ca.us'
  @test_variable = 'three'
  @params_string = params.inspect
  render(:haml=>'try.haml')
end

print content
