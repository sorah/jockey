require 'appscript'
require_relative './song'

module Jockey
  module Player
    class << self
      def app
        Appscript.app('iTunes')
      end

      def library
        app.playlists['Music'].get
      end

      def play(*args)
        app.play(*args)
      end

      def pause
        app.pause
      end

      def playing?
        app.player_state.get == :playing
      end

      def paused?
        app.player_state.get == :paused
      end

      def playing
        Song.find(app.current_track)
      end

      def prev; app.previous_track; playing; end
      def next; app.next_track; playing; end

      def playlist(x)
        app.playlists[x]
      end

      def volume; app.sound_volume.get; end
      def volume=(x); app.sound_volume.set(x); x; end

      def albums
        library.tracks.album.get.uniq.reject(&:empty?).map{|x| x.force_encoding("UTF-8") }
      end

      def album(name)
        result = library.tracks[Appscript.its.album.eq(name)].get.map {|x| Song.find(x) }
        result.empty? ? nil : result
      end

      def artists
        (library.tracks.artist.get + library.tracks.album_artist.get).reject(&:empty?).uniq.map{|x| x.force_encoding("UTF-8") }
      end

      def artist(name)
        songs = library.tracks[Appscript.its.artist.eq(name).or(Appscript.its.album_artist.eq(name))].get.map {|x| Song.find(x) }
        return nil if songs.empty?

        result = {}
        songs.each do |song|
          (result[song.album] ||= []) << song
        end
        result
      end

      def artwork(album_name)
        tracks = album(album_name)
        tracks ? tracks.first.artwork : nil
      end

      def search_album(*keywords)
        albums.select {|album| keywords.all? {|keyword| /#{Regexp.escape keyword}/i =~ album } }
      end

      def search_artist(*keywords)
        artists.select {|artist| keywords.all? {|keyword| /#{Regexp.escape keyword}/i =~ artist } }
      end

      def search_by_name(*keywords)
        library.tracks[filter(:name, *keywords)].get.map{|x| Song.find(x) }.sort.reverse
      end

      def search(*keywords)
        {albums: search_album(*keywords),
         artists: search_artist(*keywords),
         songs: search_by_name(*keywords)}
      end

      private

      def filter(attr, *keywords)
        keywords.inject(Appscript.its.send(attr).contains(keywords.shift))do |result, keyword|
          result.and(Appscript.its.send(attr).contains(keyword))
        end
      end
    end
  end
end
