require 'wunderbar'
require 'ruby2js'

# convert script blocks to JavaScript.  If binding_of_caller is available,
# full access to all variables defined in the callers scope may be made
# by execute strings (`` or %x()).

module Wunderbar
  class HtmlMarkup
    def _script(*args, &block)
      if block
        if binding.respond_to? :of_caller
          # provided by require 'binding_of_caller'
          args.unshift Ruby2JS.convert(block, binding: binding.of_caller(1))
        else
          args.unshift Ruby2JS.convert(block, binding: binding)
        end
        super *args, &nil
      else
        super
      end
    end
  end
end

module Wunderbar
  module API
    def _js(*args, &block)
      Wunderbar.ruby2js(*args, &block)
    end
  end

  def self.ruby2js(*args, &block)
    callback = Proc.new do |scope, args, block| 
      ruby2js(scope, *args, &block)
    end
    @queue << [callback, args, block]
  end
  
  class CGI
    def ruby2js(scope, *args, &block)
      headers = { 'type' => 'application/javascript', 'charset' => 'UTF-8' }

      begin
        output = Ruby2JS.convert(block) + "\n"
      rescue ::Exception => exception
        headers['status'] =  "500 Internal Server Error"
        output = "// Internal Server Error\n#{exception}\n"
      end

      out?(scope, headers) { output }
    end
  end

  module Template
    module Js
      def self.ext; :_js; end
      def self.mime; 'application/javascript'; end

      def evaluate(scope, locals, &block)
        scope.content_type self.class.default_mime_type, charset: 'utf-8'
        begin
          Ruby2JS.convert(data)
        rescue Exception => exception
          scope.response.status = 500
          "// Internal Server Error\n#{exception}\n"
        end
      end
    end

    register Js if respond_to? :register
  end
end
