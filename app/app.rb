require 'sinatra'
require 'haml'
require 'coffee_script'
require 'sass'
require 'cgi'
require 'ostruct'
require_relative './models/player'
require_relative './models/queue'
require_relative './models/song'

module Jockey
  class App < Sinatra::Base
    set :server, :thin

    set :public_folder, File.dirname(__FILE__) + '/public'
    set :views, File.dirname(__FILE__) + '/views'

    #set :haml, {}

    helpers do
      def pjax?
        params[:no_layout] || request.env['HTTP_X_PJAX']
      end

      def haml_pjax(template, options={}, locals={})
        opt = options.merge(pjax? ? {layout: false} : {})
        haml template, opt, locals
      end

      def h(str)
        CGI.escapeHTML(str)
      end

      def u(str)
        CGI.escape(str)
      end
    end
  end
end

require_relative './controllers/api'
require_relative './controllers/realtime'

require_relative './controllers/frontend'


