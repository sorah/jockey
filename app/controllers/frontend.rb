# coding: utf-8

require 'sinatra'
require_relative '../models/player'
require_relative '../models/queue'

module Jockey
  class App < Sinatra::Base
    get '/' do
      haml_pjax :songs, layout: :layout, locals: {songs: Queue.upcoming}
    end

    get '/history' do
      haml_pjax :songs, layout: :layout, locals: {songs: Queue.history}
    end

    get '/browse' do
      haml_pjax :browse, layout: :layout
    end

    get '/artist/:name' do
      artist = Player.artist(params[:name])
      if artist
        albums = artist.values
        haml_pjax :albums, layout: :layout, locals: {albums: albums}
      else
        halt 404
      end
    end

    get '/album/:name' do
      @album = Player.album(params[:name])
      if @album
        haml_pjax :album, layout: :layout, locals: {album: @album}
      else
        halt 404
      end
    end

    get '/search' do
      return halt 400 unless params[:q]
      @result = Player.search(*(params[:q].split(/ /)))
      haml_pjax :search, layout: params[:no_layout] ? false : :layout, locals: {search: params[:q]}
    end

    get '/enque/:id' do
      songs = params[:id].split(/,/).map{|x| Song.find(x) }.compact
      Queue.enque(*songs)

      redirect '/'
    end
  end
end
