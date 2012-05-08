require 'sinatra'

module Jockey
  class App < Sinatra::Base
    set :listeners, []
    set :html_listeners, []

    th = nil
    get '/api/realtime', provides: 'text/event-stream' do
      th ||= Thread.new do
        puts "Realtime Start"

        out = ->(str) do
          settings.listeners.each do |o|
            o << str
          end
        end
        html = ->(str) do
          settings.html_listeners.each do |o|
            o << str
          end
        end

        last_playing = nil
        last_upcoming = nil
        last_history = nil
        begin
          loop do
            if last_playing != (playing = Player.playing)
              out.call "event: playing\n"
              out.call "data: #{playing.to_hash.to_json}\n\n"
              html.call "event: playing\n"
              html.call "data: #{{html: haml(:song, layout: false, locals: {song: playing})}.to_json}\n\n"

              last_playing = playing
            end

            if last_upcoming != (upcoming = Queue.upcoming)
              out.call "event: upcoming\n"
              out.call "data: #{upcoming.map(&:to_hash).to_json}\n\n"
              html.call "event: upcoming\n"
              html.call "data: #{{html: haml(:songs, layout: false, locals: {songs: upcoming})}.to_json}\n\n"


              last_upcoming = upcoming
            end

            if last_history != (history = Queue.history)
              out.call "event: history\n"
              out.call "data: #{history.map(&:to_hash).to_json}\n\n"
              html.call "event: history\n"
              html.call "data: #{{html: haml(:songs, layout: false, locals: {songs: history})}.to_json}\n\n"


              last_history = history
            end

            out.call "event: ping\ndata: {\"type\": \"ping\"}\n\n"
            html.call "event: ping\ndata: {\"type\": \"ping\"}\n\n"

            sleep 1
          end
        rescue Exception => e
          p e
          p e.backtrace
          retry
        end
      end

      stream(:keep_open) do |out|
        out << "event: connected\ndata: {\"type\": \"hello\"}\n\n"

        to = params[:html] ? settings.html_listeners : settings.listeners
        to << out
        out.callback { puts "!!!"; to.delete(out) }
      end
    end
  end
end
