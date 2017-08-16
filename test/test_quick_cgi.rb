#!/usr/bin/ruby
require 'rubygems'
require 'test/unit'
require 'tempfile'
require 'nokogiri'

require './lib/quick_cgi.rb'
require 'cgi_mock.rb'
require 'mail_mock.rb'
require 'helper.rb'

class QuickCGITest < Test::Unit::TestCase
  include QuickCGITestHelper

  def setup
  end

  def teardown
  end

  def test_simple_block
    content = QuickCGI::Generator.generate(:raise_errors => true) do
      title "auto test title"
    end
    ng = Nokogiri::HTML.parse(content)
    assert_equal 1, ng.css('html').length
    assert_equal 1, ng.css('head').length
    assert_equal 1, ng.css('body').length
    assert_equal 'auto test title', ng.css('title')[0].text
  end

  def test_haml
    path = create_haml_file <<-HAML
      %h1
      %p Hello
    HAML

    content = QuickCGI::Generator.generate(:raise_errors => true) do
      title "auto test title"
      render :haml => path
    end
    ng = Nokogiri::HTML.parse(content)
    assert_equal 1, ng.css('html').length
    assert_equal 1, ng.css('head').length
    assert_equal 1, ng.css('body').length
    assert_equal 'Hello', ng.css('p')[0].text
  end

  def test_text
    content = QuickCGI::Generator.generate(:raise_errors => true) do
      title "auto test title"
      render :text => '<p>test paragraph</p>'
    end
    ng = Nokogiri::HTML.parse(content)
    assert_equal 1, ng.css('html').length
    assert_equal 1, ng.css('head').length
    assert_equal 1, ng.css('body').length
    assert_equal 'test paragraph', ng.css('p')[0].text
  end

  def test_raise_errors
    assert_raise NameError do 
      QuickCGI::Generator.generate(:raise_errors => true) do
        title "auto test title"
        render :text => '<p>test paragraph</p>'
        blah
      end
    end
  end

  def test_handle_internal_errors_with_no_email
    delivered = Mail::Message.delivered
    content = QuickCGI::Generator.generate do
      title "auto test title"
      render :text => '<p>test paragraph</p>'
      blah
    end
    ng = Nokogiri::HTML.parse(content)
    assert_equal 1, ng.css('html').length
    assert_equal 1, ng.css('head').length
    assert_equal 1, ng.css('body').length
    assert ng.css('p').any?{|el| /Error: undefined local variable/.match(el)}
    assert_equal delivered, Mail::Message.delivered
  end

  def test_error_email
    delivered = Mail::Message.delivered
    content = QuickCGI::Generator.generate(:admin_email => 'geoffk@garden-grove.org') do
      title "auto test title"
      render :text => '<p>test paragraph</p>'
      blah
    end
    ng = Nokogiri::HTML.parse(content)
    assert_equal 1, ng.css('html').length
    assert_equal 1, ng.css('head').length
    assert_equal 1, ng.css('body').length
    assert ng.css('p').any?{|el| /Error: undefined local variable/.match(el)}
    assert_equal delivered+1, Mail::Message.delivered
  end

end
