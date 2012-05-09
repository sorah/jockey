require 'sinatra'
require 'haml'
require 'coffee_script'
require 'sass'
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
        str.chars.map {|c|
          /[a-zA-Z0-9\-]/ =~ c ? c : c.bytes.map{|b| "%#{b.to_s(16).upcase}" }.join
        }.join
      end
    end
  end
end

require_relative './controllers/api'
require_relative './controllers/realtime'

require_relative './controllers/frontend'


