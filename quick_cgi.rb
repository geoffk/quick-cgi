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
  %body
    =yield
TEMP

module QuickCGI
  class Page

    attr_reader :cgi

    def initialize(options=nil)
      @title = 'QuickCGI Page Default Title'
      @master_layout_file = nil
      @cgi = CGI.new
    end

    def self.run(options=nil,&block)
      begin
        q = self.new(options)
        q.instance_eval(&block)
      rescue StandardError => e
        cgi = CGI.new
        print cgi.header
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
    end

    def render_haml(template_file)
      template_content = File.read(template_file)
      haml = Haml::Engine.new(master_layout_contents)
      output = haml.render(self) do 
        Haml::Engine.new(template_content).render(self) 
      end
      print @cgi.header + output
      exit
    end

    def render_text(text)
      haml = Haml::Engine.new(master_layout_contents)
      output = haml.render(self){ text }
      print @cgi.header + output
      exit
    end

    def master_layout_contents
      if @master_layout_file
        File.read(@master_layout_file)
      else
        DEFAULT_MASTER_LAYOUT
      end
    end

    def title(t=nil)
      return @title unless t
      @title = t
    end
    alias_method :title=, :title

    def master_template_file(f=nil)
      return @master_template_file unless f
      @master_template_file = f
    end
    alias_method :master_template_file=, :master_template_file

    def params
      @cgi.params
    end
  end
end
