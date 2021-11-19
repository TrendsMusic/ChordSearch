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
      songs, chords, chords_root, chords_ambi, chord_toSearch, chord_toSearch_root, chord_toSearch_ambi, @title, @artist, @genre, @key, @section = song.search_preparation(current_user, searchkey)
      @chord_toSearch = chord_toSearch
      @songs, @using_songs, @using_song_rate = song.using_song_rate(current_user, songs, chords)
      
      next_targets = song.getnextchords(chords, chord_toSearch)[0]
      back_targets = song.getnextchords(chords, chord_toSearch)[1]
      next_targets_root = song.getnextchords(chords_root, chord_toSearch_root)[0]
      back_targets_root = song.getnextchords(chords_root, chord_toSearch_root)[1]
      next_targets_ambi = song.getnextchords(chords_ambi, chord_toSearch_ambi)[0]
      back_targets_ambi = song.getnextchords(chords_ambi, chord_toSearch_ambi)[1]
      #進行率計算
      @next_targets_root_rate = song.chord_calculate(next_targets_root)[0]
      @back_targets_root_rate = song.chord_calculate(back_targets_root)[0]
      @next_targets_ambi_rate = song.chord_calculate(next_targets_ambi)[1]
      @back_targets_ambi_rate = song.chord_calculate(back_targets_ambi)[1]
      #next_targets_rate = song.chord_calculate(next_targets)
      #back_targets_rate = song.chord_calculate(back_targets)
      
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
      chords_attributes:[fields_attributes:[:part1, :part2, :part3, :part4, :part5, :part6, :part7, :part8, :_destroy]])
    end
    
    def index_serch_params
      params.permit(:title, :artist, :genre, :key)
    end
    
end
