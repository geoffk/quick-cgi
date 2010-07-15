# QuickCGI
# Library to assist in the making of CGI pages using HAML.
#
# Usage:
# QuickCGI::Page.run do
#   title "My title"
#   @my_variable = "Hello"
#   render_haml('file.haml')
# end

require 'cgi'
require 'haml'

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
      @page_contents = nil
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

    def render_haml(template_file)
      template_content = File.read(template_file)
      @page_contents = Haml::Engine.new(template_content).render(self) 
    end

    def render_text(text)
      @page_contents = text
    end

    def title(t=nil)
      return @title unless t
      @title = t
    end
    alias_method :title=, :title

    def master_layout_file(f=nil)
      return @master_layout_file unless f
      @master_layour_file = f
    end
    alias_method :master_layout_file=, :master_layout_file

    def params
      @cgi.params
    end
  end
end
