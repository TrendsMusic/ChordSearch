class Song < ApplicationRecord
  belongs_to :user
  has_many :chords, dependent: :destroy
  accepts_nested_attributes_for :chords, allow_destroy: true
  
  #CSVファイル読み込み
  def self.import(user, file)
  require "csv"
    CSV.foreach(file.path, headers: true) do |row|
      title = row[0]
      artist = row[1]
      genre = row[2]
      section_numbar = row[3]
      key = row[4]
      content = row[5].gsub(/\s/, '') if (row[5] != nil)
        if (title != nil)
            #同じ曲が登録された場合、一度その曲を削除する
            song = user.songs.where(user_id:user.id, title:title, artist:artist, genre:genre)
            if song.present?
              song.destroy_all
            end
            #楽曲の登録
            song = user.songs.find_or_create_by(user_id:user.id, title:title, artist:artist, genre:genre)
            song.chords.find_or_create_by(section_numbar:section_numbar, content:content, key:key)
        elsif (title == nil && artist == nil &&  content != nil && section_numbar != nil)
            #カラムを補完して登録
            title = user.songs.pluck(:title).last
            artist = user.songs.pluck(:artist).last
            if (genre == nil)
            genre = user.songs.pluck(:genre).last
            end
            song = user.songs.find_or_create_by(user_id:user.id, title:title, artist:artist, genre:genre)
            if (key == nil)
              key_songs = Chord.where(song_id: song.id)
              key = key_songs.pluck(:key).last
            end 
            song.chords.find_or_create_by(section_numbar:section_numbar, content:content, key:key)
        end
    end
  end
  
  #コード進行を予想する楽曲の範囲を指定、フォームから値の受け取り
  def search_preparation(current_user,searchkey)
      title = searchkey[:title]
      artist = searchkey[:artist]
      genre = searchkey[:genre]
      key = searchkey[:key]
      section_numbar = searchkey[:section_numbar]
      chord_toSearch = ""
      chords_input = searchkey[:chords_attributes]["0"]
      chords_input[:fields_attributes].each do |key, data|
          chord_toSearch += data[:part1] + data[:part2] + data[:part3] + data[:part4] + data[:part5]
      end 
    if (title == "") && (artist == "") && (genre == "") 
        songs = current_user.songs
        chord = Chord.where(song_id: songs.ids)
        unless (key == "" || section_numbar == "")
          chord = chord.where(key:key, section_numbar:section_numbar)
        end
        chords = chord.with_content_regexp(chord_toSearch).pluck(:content)
        
    else
        songs = current_user.songs.where("title like? AND artist like? AND genre like?", "%#{title}%", "%#{artist}%", "%#{genre}%")
        chord = Chord.where(song_id: songs.ids)
        unless (key == "" || section_numbar == "")
          chord = chord.where(key:key, section_numbar:section_numbar)
        end
        chords = chord.with_content_regexp(chord_toSearch).pluck(:content)
    end
    return [songs, chords, chord_toSearch]
  end
  
  #コードの使用率を算出する
  def using_song_rate (current_user, songs, chords)
    using_songs= songs.joins(:chords).where(chords: {content: chords}).uniq
    #選択した範囲内でそのコード進行がどのくらい楽曲に採用されているか割合を算出する。
    unless songs.count == 0
      using_chord_rate = (using_songs.length/songs.count.to_f)*100
    else
      using_chord_rate = 0
    end
    return [using_songs, using_songs.length, using_chord_rate]
  end
  
  #選択されたコードから次のコード進行を予想する。
  def getnextchords(chords, search_chords)
      if (chords != nil)
        nextchords_000 = Array.new
        chords.each do |chord|
            if chord == nil
                return [nil, 0]
            else
              chord = chord
              nextchords_000 << chord.scan(/#{search_chords}((♭|#)?[Ⅰ-Ⅶ](M|m)?(dim)?(aug)?(sus4)?(sus2)?(7)?(6)?(♭5)?(9)?(add9)?(♭9)?(#9)?(11)?(#11)?(13)?(♭13)?(omit3)?(omit5)?(on[Ⅰ-Ⅶ](♭|#)?)?)/)
            end
        end
        #binding.pry 
        nextchords = Array.new
        nextchords_000.each do |nextchords_00|
          nextchords_00.each do |nextchords_0|
            nextchords << nextchords_0.first
          end
        end
        return [nextchords, nextchords.length]
        
      else
        raise "Not Found"
      end
  end
    
  # 更新するカラムを定義する
  def self.updatable_attributes
    ["id", "title", "artist", "key", "genre", ""]
  end
end
