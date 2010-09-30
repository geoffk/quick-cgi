# QuickCGI
# Library to assist in the making of CGI pages using HAML.
#
# Usage:
#
# require 'quick_cgi' 
#
# content = QuickCGI::Generator.generate(:admin_email => 'geoffk@garden-grove.org') do
#   title "My title"
#   @my_variable = "Hello"
#   render(:haml=>'file.haml')
#   render(:text=>'<p>My html text</p>')
# end
#
# print content
#

require 'cgi'
require 'haml'
require 'mail'

DEFAULT_MASTER_LAYOUT = <<TEMP
%html
  %head
    %title=@title
    %link{:type=>'text/css', :href=>'/standard.css', :rel=>'stylesheet'}
  %body
    %div.title=@title
    =yield
TEMP



module QuickCGI

  class Page
    attr_reader :cgi, :page_contents, :options

    def initialize(options={})
      @title = 'QuickCGI Page Default Title'
      @master_layout_file = nil
      @cgi = CGI.new
      @page_contents = ""
      @admin_email = nil
    end

    def generate
      if master_layout_file
        layout = File.read(q.master_layout_file)
      else
        layout = DEFAULT_MASTER_LAYOUT
      end
      haml = Haml::Engine.new(layout)
      output = ""
      output << cgi.header if ENV['REQUEST_METHOD'] 
      output << haml.render(self){ page_contents }
    end

    # Render something to the page.  You must specify the type of render to perform: haml, 
    # partial or text.
    #
    # haml: Renders the given haml file to the @page_contents buffer
    # example: 
    #   render(:haml => 'myfile.haml')
    #
    # text: Renders the text to the @page_contents buffer
    # example: 
    #   render(:text => '<p>A paragraph to put on the page</p>'
    #
    # partial: Returns the results of rendering the given haml file, only 
    # useful inside an existing haml file.
    # example:
    #   = render(:partial => 'mypartial.haml')
    #
    # Note that it is possible to make multiple haml and text renders to the same page.  Each
    # piece of content will simply be appended to the page.
    #
    def render(options)
      if options[:haml]
        template_content = File.read(options[:haml])
        @page_contents << Haml::Engine.new(template_content).render(self) 
      elsif options[:partial]
        template_content = File.read(options[:haml])
        return Haml::Engine.new(template_content).render(self) 
      elsif options[:text]
        @page_contents << options[:text]
      else
         raise "No render type found.  Must be haml, partial or text"
      end
    end

    # Set or return the title instance variable that is used in the default master layout
    def title(t=nil)
      return @title unless t
      @title = t
    end
    alias_method :title=, :title

    # Set or return an alternative haml file to be used as the master layout
    def master_layout_file(f=nil)
      return @master_layout_file unless f
      @master_layour_file = f
    end
    alias_method :master_layout_file=, :master_layout_file

    # Set or return admin email address for error emails
    def admin_email(e=nil)
      return @admin_email unless e
      @admin_email = e
    end
    alias_method :admin_email=, :admin_email

    # Returns a hash of the CGI parameters
    def params
      raise "Invalid CGI" unless @cgi
      @cgi.params
    end
  end

  class Generator
    def self.generate(options={},&block)
      @@options = {
        :raise_errors => false, # Raises errors instead of handling them internally
        :admin_email => nil
      }.merge(options)
      begin
        q = Page.new(options)
        q.instance_eval(&block) 
        q.generate
      rescue StandardError => e
        if @@options[:raise_errors]
          raise
        else
          email_error(e,q.params) if @@options[:admin_email]
          display_error(e,q.params)
        end
      end
    end

    def self.display_error(e,params=nil)
      output = ""
      output << CGI.new.header if ENV['REQUEST_METHOD']
      output+= <<-END_ERROR
        <html>
          <head>
            <title>Error found!</title>
          </head>
          <body>
            <h1>There was an error generating the page!</h1>
            <p><b>Params:</b> #{params.inspect}</p>
            <p><b>Error: #{e}</b></p>
            <p>#{e.backtrace.join('<br>')}</p>
          </body>
        </html>
      END_ERROR
    end

    def self.email_error(e,params=nil)
      return unless @@options[:admin_email]
      mail = Mail.new do
        from 'quick_cgi@ch'
        to @@options[:admin_email]
        subject "CGI ERROR: #{$0}"
        body %|Params: #{params.inspect}\nError: #{e}\n#{e.backtrace.join("\n")}|
      end
      mail.deliver!
    end
  end

end
