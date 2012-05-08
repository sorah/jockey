# coding: utf-8
require 'appscript'

# do like this: http://hints.macworld.com/article.php?story=20040830035448525
def make_next(*songs)
  songs.flatten!

  app = Appscript.app('iTunes')
  playlist = app.playlists['iTunes DJ']
  offset = 6

  size = playlist.tracks.get.size


  songs.each do |song|
    song.duplicate to: playlist
  end

  exists = playlist.tracks[Appscript.its.index.gt(offset).and(Appscript.its.index.le(size))]
  exists.duplicate to: playlist

  exists = playlist.tracks[Appscript.its.index.gt(offset).and(Appscript.its.index.le(size))]
  playlist.delete exists

  return
  songs.each do |song|
    playlist.delete playlist.tracks[Appscript.its.persistent_ID.eq(song.persistent_ID.get).and(Appscript.its.index.gt(offset+songs.size))]
  end
end

def make_next(track)
  app = Appscript.app('iTunes')

  # Get the playlist
  playlist = app.playlists['iTunes DJ']

  # offset: iTunes DJ playlist has "recently played" songs.
  #         this gets an index of the current track.
  #         this method doesn't touch songs before the index (= recently played songs).
  offset = app.current_track.index.get
  # size: get the iTunes DJ playlist's size.
  #       this will be used as index of playlist's last.
  size = playlist.tracks.get.size

  # Add the track to last.
  track.duplicate to: playlist

  # Add the existing tracks (offset < track.index <= size) to last
  tracks = playlist.tracks[Appscript.its.index.gt(offset).and(Appscript.its.index.le(size))]
  p tracks.name.get.map{|x| x.force_encoding("UTF-8") }
  tracks.duplicate to: playlist

  # delete the existing tracks.
  playlist.delete tracks

  # delete the duplicates.
  playlist.delete playlist.tracks[Appscript.its.persistent_ID.eq(track.persistent_ID.get).and(Appscript.its.index.gt(offset+1))]
end

make_next Appscript.app('iTunes').tracks['さよならメモリーズ']#, Appscript.app('iTunes').tracks['ヒーロー']


