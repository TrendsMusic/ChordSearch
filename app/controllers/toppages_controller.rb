class ToppagesController < ApplicationController
  def index
    @song = Song.new
    @chord = @song.chords.build
    @field = @chord.fields.build
  end
end
