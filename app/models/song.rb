require 'appscript'
require_relative './player'

module Jockey
  class Song
    class NotFound < Exception; end

    class << self
      def cache; @cache ||= {}; end
      def cache=(o); @cache = o; end

      def find(o)
        begin
          case o
          when Appscript::Reference
            id = o.persistent_ID.get
            cache[id] ||= self.new(id)
          when String
            cache[o] ||= self.new(o)
          end
        rescue NotFound
          nil
        end
      end
    end

    def initialize(id)
      @id = id
      @record = Player.library.tracks[Appscript.its.persistent_ID.eq(@id)].first.get

      raise NotFound unless @record

      @name = @record.name.get.force_encoding("UTF-8")
      @artist = @record.artist.get.force_encoding("UTF-8")
      @album = @record.album.get.force_encoding("UTF-8")
      @album_artist = @record.album_artist.get.force_encoding("UTF-8")
      @artwork_exist = true
      @artwork = nil
    end

    attr_reader :record, :id, :name, :artist, :album, :album_artist

    def artwork
      return @artwork if @artwork
      return nil unless @artwork_exist
      @artwork_exist = !(@record.artworks.get.empty?)
      return nil unless @artwork_exist
      @artwork = @record.artworks[1].raw_data.get.data
    end

    def to_hash
      {id: @id, name: @name, artist: @artist, album: @album, album_artist: @album_artist, rating: rating, played: played}
    end

    def inspect
      "#<Song #{@id}: #{@name} - #{@album} (#{@artist})>"
    end

    def played
      @played ||= @record.played_count.get
    end

    def rating
      @rating ||= @record.rating.get
    end

    def <=>(o)
      a = rating <=> o.rating
      a.zero? ? played <=> o.played : a
    end

    include Comparable

    def ==(o); o.class == self.class && @id == o.id; end
    alias eql? ==
    alias equal? ==

    def hash
      (@id.hash/42)*14
    end

  end
end
