#!/usr/bin/ruby
require 'rubygems'
require 'test/unit'
require 'tempfile'
require 'nokogiri'

require 'lib/quick_cgi.rb'
require 'cgi_mock.rb'
require 'mail_mock.rb'
require 'helper.rb'

class QuickCGITest < Test::Unit::TestCase
  include QuickCGITestHelper

  def setup
    @haml_file = Tempfile.new('quick_cgi_test')
    @haml_file.open
  end

  def teardown
    @haml_file.close(true)
  end

  def test_haml_string
    src = <<-HAML
      first line
        second line
        third line indented
        fourth line indented
      fifth line
        sixth line indented
          seventh line indented twice
    HAML
 
    should_be = src.split("\n").map{|l| l[6 .. -1]}.join("\n")
    assert_equal should_be, haml_string(src)
  end

  def test_simple_block
    @haml_file.write <<-HAML
      %h1
      %p=Hello
    HAML
    content = QuickCGI::Page.generate do
      title "my title"
    end
    ng = Nokogiri::HTML.parse(content)
    assert_equal 1, ng.css('html').length
    assert_equal 1, ng.css('head').length
    assert_equal 1, ng.css('body').length
    assert_equal 'my title', ng.css('title')[0].text
  end


end
