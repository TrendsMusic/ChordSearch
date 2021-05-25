class SongsController < ApplicationController
before_action :require_user_logged_in 

    def index
        @songs = current_user.songs
    end
    
    def import
        Song.import(current_user, params[:file])
        redirect_to songs_url
    end

    def search
      searchkey =  song_search_params
      song = Song.new
      songs, chords, chord_toSearch = song.search_preparation(current_user, searchkey)
      @chord_toSearch = chord_toSearch
      @songs, @using_songs, @using_song_rate = song.using_song_rate(current_user, songs, chords)
      @count = song.getnextchords(chords, chord_toSearch)[1]
    end
    
    def index_serch
      searchkey =  index_serch_params
      title = searchkey[:title]
      artist = searchkey[:artist]
      genre = searchkey[:genre]
      key = searchkey[:key]
      unless  (key == "")
        songs  = current_user.songs.joins(:chords).where(chords: {key:key})
      else
        songs = current_user.songs
      end
      @songs = songs.where("title like? AND artist like? AND genre like?", "%#{title}%", "%#{artist}%", "%#{genre}%").uniq
      render :index
    end
    
    def destroy
      @songs =current_user.songs
      @songs.destroy_all
      flash[:success] = "楽曲のデータを削除しました"
      redirect_to songs_url
    end

    private
    
    def song_search_params
      params.require(:song).permit(:title, :artist, :genre, :key, :section_numbar, 
      chords_attributes:[fields_attributes:[:part1, :part2, :part3, :part4, :part5, :_destroy]])
    end
    
    def index_serch_params
      params.permit(:title, :artist, :genre, :key)
    end
    
end
