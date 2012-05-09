require 'appscript'
require_relative './player'
require_relative './song'

module Jockey
  class Queue
    PLAYLIST = 'iTunes DJ'

    class << self
      def playlist
        Player.playlist(PLAYLIST)
      end

      def lock
        @lock = Mutex.new
      end

      def offset
        if Player.playing? && Jockey::Player.app.current_playlist.name.get == PLAYLIST
          @offset = Player.app.current_track.index.get
        elsif !@offset
          p @offset
          Player.play(playlist)
          @offset = Player.app.current_track.index.get
        end

        @offset
      end

      # "enque", it's named enque but it doesn't add to the last!
      def enque(*songs)
        # do like this: http://hints.macworld.com/article.php?story=20040830035448525
        # enque(d):
        #
        # 1. [a, b, c]
        # 2. [a, b, c, d]
        # 3. [a, b, c, d, a*, b*, c*]
        # 4. [d, a*, b*, c*]

        songs.flatten!
        songs.map!(&:record)

        lock.synchronize do # because it's not simple steps
          app = Appscript.app('iTunes')

          size = playlist.tracks.get.size

          exists = playlist.tracks[Appscript.its.index.gt(offset).and(Appscript.its.index.le(size))]

          songs.each do |song|
            song.duplicate to: playlist
          end
          exists.duplicate to: playlist

          playlist.delete exists
          songs.each do |song|
            playlist.delete playlist.tracks[Appscript.its.persistent_ID.eq(song.persistent_ID.get).and(Appscript.its.index.gt(offset+songs.size))]
          end
        end
      end

      def history
        playlist.tracks[Appscript.its.index.lt(offset)].get.map{|x| Song.find(x) }.reverse
      end

      def upcoming
        playlist.tracks[Appscript.its.index.gt(offset)].get.map{|x| Song.find(x) }
      end

      def current
        Song.find playlist.tracks[offset].get
      end
    end
  end
end
