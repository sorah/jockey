require 'appscript'
require_relative './player'

module Jockey
  class Song
    class NotFound < Exception; end

    def self.find(*args)
      begin
        self.new(*args)
      rescue NotFound
        nil
      end
    end

    def initialize(o)
      case o
      when Appscript::Reference
        @record = o
        @id = o.persistent_ID.get
      when String
        @id = o
        @record = Player.library.tracks[Appscript.its.persistent_ID.eq(@id)].get[0]
      else
        raise ArgumentError, "should be Appscript::Reference or String"
      end

      raise NotFound unless @record

      @name = @record.name.get.force_encoding("UTF-8")
      @artist = @record.artist.get.force_encoding("UTF-8")
      @album = @record.album.get.force_encoding("UTF-8")
      @album_artist = @record.album_artist.get.force_encoding("UTF-8")
    end

    def artwork
      return nil if @record.artworks.get.empty?
      @record.artworks[1].raw_data.get.data
    end

    def to_hash
      {id: @id, name: @name, artist: @artist, album: @album, album_artist: @album_artist, rating: rating, played: played}
    end

    def inspect
      "#<Song #{@id}: #{@name} - #{@album} (#{@artist})>"
    end

    def played
      @record.played_count.get
    end

    def rating
      @record.rating.get
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

    attr_reader :record, :name, :id, :artist, :album, :album_artist
  end
end
