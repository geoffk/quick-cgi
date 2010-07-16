# QuickCGI
# Library to assist in the making of CGI pages using HAML.
#
# Usage:
# QuickCGI::Page.run do
#   title "My title"
#   @my_variable = "Hello"
#   render(:haml=>'file.haml')
#   render(:text=>'<p>My html text</p>')
# end
#
# Tip: Set $DEBUG to true to disable email on errors

require 'cgi'
require 'haml'
require 'mail'

DEFAULT_MASTER_LAYOUT = <<TEMP
%html
  %head
    %title=@title
    %style{:type=>'text/css'}
      body { font-family: verdana, arial; }
      div.header { width: 100%; height: 40px; background-color: #0000ff; text-align: center; display: block; vertical-align: bottom; font-family: verdana, arial, sans-serif; color: white; font-weight: bold; font-size: 24px; }
      span.comments { font-size: 12px; color: #777; display: block; }
      td { vertical-align: top; }
      input.submit { font-weight: bold; }
  %body
    %div.header=@title
    =yield
TEMP

module QuickCGI
  class Page

    attr_reader :cgi, :page_contents

    def initialize(options=nil)
      @title = 'QuickCGI Page Default Title'
      @master_layout_file = nil
      @cgi = CGI.new
      @page_contents = ""
      @admin_email = nil
    end

    def self.run(options=nil,&block)
      begin
        q = self.new(options)
        q.instance_eval(&block)
        if q.master_layout_file
          layout = File.read(q.master_layout_file)
        else
          layout = DEFAULT_MASTER_LAYOUT
        end
        haml = Haml::Engine.new(layout)
        print haml.render(q){ q.page_contents }
      rescue StandardError => e
        display_error(e)
        email_error(q.admin_email,e) unless $DEBUG
      end
    end

    def self.display_error(e)
      print <<-END_ERROR
        <html>
          <head>
            <title>Error found!</title>
          </head>
          <body>
            <h1>There was an error generating the page!</h1>
            <p><b>Error: #{e}</b></p>
            <p>#{e.backtrace.join('<br>')}</p>
          </body>
        </html>
      END_ERROR
    end

    def self.email_error(email,e)
      return unless email
      mail = Mail.new do
        from ENV['USER'] + '@' + ENV['HOSTNAME']
        to email
        subject "CGI ERROR: #{$0}"
        body %|Error: #{e}\n#{e.backtrace.join("\n")}|
      end
      mail.deliver!
    end

    # Render something to the page.  You must specify the type of render to perform: haml, partial or text.
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
      @cgi.params
    end
  end
end
